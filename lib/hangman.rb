# frozen_string_literal: true

# Module: DictionaryWordSelector
#
# This module provides a method for generating a secret word by selecting a random word from a provided dictionary file.
# The dictionary file is expected to be a text file containing a list of words, with one word per line.
# Words in the dictionary file must be between 5 and 12 characters in length to be considered valid.
module DictionaryWordSelector
  def generate_secret_word
    dictionary = File.read('dictionary.txt').split
    valid_words = []

    dictionary.each do |word|
      valid_words << word if word.to_s.length >= 5 && word.to_s.length <= 12
    end

    secret_word = valid_words.sample
    return secret_word
  end
end

class Game
  include DictionaryWordSelector

  def initialize
    @secret_word = generate_secret_word
  end
end
