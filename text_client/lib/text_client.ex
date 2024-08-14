defmodule TextClient do
  @spec start() :: :ok
  def start() do
    TextClient.Runtime.RemoteHangman.connect()
    |> TextClient.Impl.Player.start()
  end

  @spec start_computer() :: :ok
  def start_computer() do
    TextClient.Runtime.RemoteHangman.connect()
    |> TextClient.Impl.Computer.start()
  end
end
