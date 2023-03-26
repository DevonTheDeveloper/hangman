# frozen_string_literal: true

require 'colorize'

# This module provides a method for generating a secret word by selecting a random word from a provided dictionary file.
module DictionaryWordSelector
  def generate_secret_word
    dictionary = File.read('dictionary.txt').split
    valid_words = []

    dictionary.each do |word|
      valid_words << word if word.to_s.length >= 5 && word.to_s.length <= 12
    end

    valid_words.sample
  end
end

module PlayerInputHandler
  def get_player_input
    puts "Enter a letter, or enter ‘save’ to save progress:\n"
    player_input = gets.chomp.downcase

    until valid_player_input?(player_input)
      system('clear')
      puts "Enter a letter, or enter ‘save’ to save progress:\n"
      player_input = gets.chomp.downcase
    end
    if player_input == 'save'
      save_game_progress
    end
    player_input
  end

  def valid_player_input?(player_input)
    if player_input.match?(/^[a-z]{1}$/) || player_input == 'save'
      true
    end
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

class Game
  include DictionaryWordSelector
  include PlayerInputHandler

  def initialize
    @secret_word = generate_secret_word
    get_player_input
  end
end

Game.new
