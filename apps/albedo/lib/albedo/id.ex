defmodule Albedo.Id do
  use Agent

  @doc """
  Start a new ID agent
  """
  def start_link() do
    Agent.start_link(fn -> :pause end)
  end

  @doc """
  get current id
  """
  def get(pid) do
    Agent.get(pid, fn state -> state end)
  end

  @doc """
  start a new ID
  """
  def start(pid,{latitude, longitude, date, time}) do
    current =
      Agent.get(pid, fn state -> state end)

    case current do
      :pause ->
        id = new_id(latitude, longitude, date, time)
        Agent.update(pid, fn (_state) -> id end)
      _ -> current
    end
  end

  @doc """
  pause the ID return
  """
  def pause(pid) do
    current  = Agent.get(pid, fn state -> state end)
    case current do
      :pause -> current
      _ -> Agent.update(pid, fn (_state) -> :pause end)
    end
  end

  defp new_id(latitude, longitude, date, time) do
    id_string = Float.to_string(latitude) <> Float.to_string(longitude) <> Date.to_string(date) <> Time.to_string(time)
    :crypto.hash(:md5, id_string)
    |> Base.encode64
    |> String.downcase
  end

end
