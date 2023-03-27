# frozen_string_literal: true

require 'colorize'

# This module provides a method for generating a secret word
# by selecting a random word from a provided dictionary file.
module DictionaryWordSelector
  def generate_secret_word
    dictionary = File.read('dictionary.txt').split
    valid_words = []

    dictionary.each do |word|
      valid_words << word if word.to_s.length >= 5 && word.to_s.length <= 12
    end

    word = valid_words.sample
    word.to_s
  end
end

# This module provides methods for handling user input in a hangman game.
# The primary method is `get_player_input`,
# which prompts the player to enter a letter or save their progress.
module PlayerInputHandler
  def get_player_input
    puts "Enter a letter, or enter ‘save’ to save progress:\n"
    player_input = gets.chomp.downcase

    until valid_player_input?(player_input)
      system('clear')
      puts "Enter a letter, or enter ‘save’ to save progress:\n"
      player_input = gets.chomp.downcase
    end
    save_game_progress if player_input == 'save'
    player_input
  end

  def valid_player_input?(player_input)
    return unless player_input.match?(/^[a-z]{1}$/) || player_input == 'save'

    true
  end

  def save_game_progress
    system('clear')
    puts "Feature has not been implemented yet.\n".red
    get_player_input
    # puts "Name your save file:\n"
    # save_file_name = gets.chomp
    # puts 'Game has been saved!'
  end
end

# This module provides a method for displaying the progress made by players in a hangman game.
# The `display_progress`
# method takes a `word` and a `guess` as arguments and prints out a string
# representing the progress made by the player
# so far. The method uses the `match_letters` helper method to update
# a progress array with correctly guessed letters.
module DisplayProgress
  def display_progress(word, guess)
    progress = []
    word.length.times do
      progress << '_'
    end
    match_letters(guess, word, progress)

    puts progress.join
  end

  def match_letters(guess, word, progress_array)
    word.chars.each_with_index do |letter, index|
      progress_array[index] = letter if letter == guess
    end
  end
end

class Game
  include DisplayProgress
  include PlayerInputHandler
  include DictionaryWordSelector

  def initialize
    @secret_word = generate_secret_word
    @player_input = get_player_input
    display_progress(@secret_word, @player_input)
  end
end

Game.new
