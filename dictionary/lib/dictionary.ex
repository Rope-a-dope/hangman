defmodule Dictionary do
  alias Dictionary.Runtime.Server
  alias Dictionary.Impl.WordList

  @spec random_word() :: String.t()
  defdelegate random_word(), to: Server

  @spec all_words_with_length(integer()) :: WordList.t()
  defdelegate all_words_with_length(len), to: Server
end
