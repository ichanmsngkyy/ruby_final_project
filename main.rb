# frozen_string_literal: true

require_relative 'lib/board'
require_relative 'lib/game'
require_relative 'lib/player'
require_relative 'lib/aiplayer'
# Starter
class Main
  def self.start
    puts 'Welcome to Ruby Chess!'
    puts '1. New Game (Human vs Human)'
    puts '2. New Game (Human vs AI)'
    puts '3. Load Game'
    puts '4. List Saved Games'
    puts '5. Exit'

    choice = gets.chomp.to_i

    case choice
    when 1
      start_human_game
    when 2
      start_ai_game
    when 3
      load_game
    when 4
      list_saves
    when 5
      puts 'Thanks for playing!'
    else
      puts 'Invalid choice!'
      start
    end
  end

  def self.start_human_game
    puts 'Enter Player 1 name (White):'
    player1_name = gets.chomp
    puts 'Enter Player 2 name (Black):'
    player2_name = gets.chomp

    game = Game.new(player1_name, player2_name)
    game.play
  end

  def self.start_ai_game
    puts 'Enter your name:'
    player_name = gets.chomp
    puts 'Select AI difficulty: (1) Easy, (2) Medium, (3) Hard'
    difficulty_choice = gets.chomp.to_i

    difficulty = case difficulty_choice
                 when 1 then :easy
                 when 2 then :medium
                 when 3 then :hard
                 else :easy
                 end

    game = Game.new(player_name, 'Computer', difficulty)
    game.play
  end

  def self.load_game
    saves = SaveFile.list_saves
    if saves.empty?
      puts 'No saved games found.'
      return
    end

    puts 'Available saves:'
    saves.each_with_index { |save, idx| puts "#{idx + 1}. #{save}" }

    puts 'Enter save number:'
    choice = gets.chomp.to_i - 1

    if choice.between?(0, saves.length - 1)
      game = SaveFile.load_game(saves[choice])
      game&.play
    else
      puts 'Invalid choice!'
    end
  end

  def self.list_saves
    saves = SaveFile.list_saves
    if saves.empty?
      puts 'No saved games found.'
    else
      puts 'Saved games:'
      saves.each { |save| puts "- #{save}" }
    end
  end
end

Main.start
