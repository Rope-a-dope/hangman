defmodule TextClient.Runtime.RemoteHangman do
  @remote_server :"hangman@Rope-a-dope"
  def connect() do
    :rpc.call(@remote_server, Hangman, :new_game, [])
  end
end
