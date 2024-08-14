defmodule Dictionary.Runtime.Server do
  @type t :: pid()
  alias Dictionary.Impl.WordList
  @me __MODULE__

  use Agent

  def start_link(_) do
    Agent.start_link(&WordList.word_list/0, name: @me)
  end

  def random_word() do
    Agent.get(@me, &WordList.random_word/1)
  end

  def all_words_with_length(len) do
    Agent.get(@me, fn word_list ->
      WordList.all_words_with_length(word_list, len)
    end)
  end
end
