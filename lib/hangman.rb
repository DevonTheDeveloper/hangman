# frozen_string_literal: true

require 'colorize'
require 'yaml'

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
  def fetch_player_input
    puts "Enter a letter, or enter ‘save’ to save progress:\n"
    player_input = gets.chomp.downcase

    until valid_player_input?(player_input)
      system('clear')
      puts "Enter a letter, or enter ‘save’ to save progress:\n"
      player_input = gets.chomp.downcase
    end

    player_input
  end

  def valid_player_input?(player_input)
    unless player_input.match?(/^[a-z]{1}$/) || player_input == 'save' || player_input == 'quit'
      return
    end

    true
  end

  def add_guess(player_input, guessed_array)
    guessed_array << player_input unless guessed_array.any?(player_input)
  end
end

# This module provides a method for displaying the progress made by players in a hangman game.
# The `display_progress`
# method takes a `word` and a `guess` as arguments and prints out a string
# representing the progress made by the player
# so far. The method uses the `match_letters` helper method to update
# a progress array with correctly guessed letters.
module DisplayProgress
  def display_progress(word, guess, progress)
    match_letters(guess, word, progress)

    puts progress.join
    progress
  end

  def match_letters(guess, word, progress_array)
    word.chars.each_with_index do |letter, index|
      progress_array[index] = letter if letter == guess
    end
  end

  def no_matches?(guess, word)
    matches = 0
    word.chars.each do |letter|
      matches += 1 if letter == guess
    end

    matches.zero?
  end
end

# This module provides methods for declaring the outcome of a hangman game.
module WinLossDeclaration
  def word_guessed?(guessed, word)
    true if guessed.join == word
  end

  def declare_win
    puts 'You win! You’ve guessed the word.'.green
  end

  def declare_loss(word)
    puts "You lost! You couldn’t guess the word. The word was #{word}".red
  end
end

# This module provides methods to handle the saving and loading of a game in YAML format.
module SaveLoadHandler
  def save_game
    print "\nName your save file: "
    filename = gets.chomp
    dump = save_to_yaml
    return if filename.include?('.')

    if File.exist?("saved/#{filename}.yaml")
      puts "Would you like to overwrite #{filename}.yaml? [y/n]"
      answer = gets.chomp
      return if answer != 'y'

      File.write("saved/#{filename}.yaml", dump)
      puts 'File overwritten!'
    else
      File.new("saved/#{filename}.yaml", 'w')
      File.write("saved/#{filename}.yaml", dump)
      puts 'Game has been saved!'
    end
  end

  def save_to_yaml
    YAML.dump(
      'secret_word' => @secret_word,
      'progress' => @progress,
      'incorrect_guesses_left' => @incorrect_guesses_left,
      'guessed' => @guessed
    )
  end

  def load_game
    if Dir.glob('saved/*').empty?
      system('clear')
      puts 'No saved files to load.'.red
      start_game
    end

    filename = select_game
    file = YAML.safe_load(File.read(filename))

    self.secret_word = file['secret_word']
    self.guessed = file['guessed']
    self.incorrect_guesses_left = file['incorrect_guesses_left']
    self.progress = file['progress']

    display_variables
    run
  end

  def select_game
    saved_array = Dir.glob('saved/*')

    puts "Select your saved game:\n"

    saved_array.each_with_index do |file, index|
      puts "[#{index + 1}] - #{file[6..]}"
    end
    puts "\n"
    file_index = gets.chomp.to_i

    return unless file_index.is_a? Integer

    saved_array[file_index - 1].to_s
  end
end

# This class represents a Hangman game. It includes modules for displaying progress,
# handling player input, selecting a secret word from a dictionary,
# and handling win/loss declaration and saving/loading of the game state.
class Game
  include DisplayProgress
  include PlayerInputHandler
  include DictionaryWordSelector
  include WinLossDeclaration
  include SaveLoadHandler

  attr_accessor :secret_word, :progress, :incorrect_guesses_left, :guessed

  def initialize
    @secret_word = generate_secret_word
    @progress = []
    @secret_word.length.times do
      @progress << '_'
    end
    @incorrect_guesses_left = 10
    @guessed = []
    start_game
  end

  def start_game
    loop do
      puts "What would you like to do?\n[1] Create a new game\n[2] Load a saved game"
      answer = gets.chomp
      next unless %w[1 2].include?(answer)

      case answer
      when '1'
        run
      when '2'
        load_game
      end
      break
    end
  end

  def display_variables
    puts "You’ve guessed: #{@guessed.join(' ').blue}"
    display_progress(@secret_word, @player_input, @progress)

    if @incorrect_guesses_left.between?(5, 10)
      puts "\n#{@incorrect_guesses_left} incorrect guesses left.\n".green
    else
      puts "\n#{@incorrect_guesses_left} incorrect guesses left.\n".red
    end
  end

  def run
    loop do
      @player_input = fetch_player_input
      save_game if @player_input == 'save'
      next if @player_input == 'save'

      add_guess(@player_input, @guessed) unless @guessed.include?(@player_input)

      if no_matches?(@player_input, @secret_word) && @guessed.any?(@player_input)
        @incorrect_guesses_left -= 1
      end

      display_variables

      break declare_win if word_guessed?(@progress, @secret_word)
      break declare_loss(@secret_word) if @incorrect_guesses_left.zero?
    end
  end
end

Game.new
