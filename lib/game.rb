# frozen_string_literal: true

require_relative 'board'
require_relative 'pieces/piece'
require_relative 'pieces/rook'
require_relative 'pieces/bishop'
require_relative 'pieces/knight'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'

# Game Class File
class Game
  attr_reader :board, :current_player, :players, :game_status

  def initialize(player1, player2)
    @board = Board.new
    @players = [player1, player2]
    @current_player = @players[0]
    @game_status = :in_progress
  end

  def play
    setup_players
    puts "#{@players[0].name} (White) vs #{@players[1].name} (Black)"
    puts "Let's Begin"
    puts

    @current_player = @players[0]

    until game_over?
      display_board
      display_current_player

      move = get_player_move

      if make_move(move[:start], move[:end])
        check_game_status
        switch_player unless game_over?
      else
        puts 'Invalid move! Try Again'
        puts
      end
    end
    display_final_result
  end

  def make_move(start_pos, end_pos)
    true
  end

  private

  def setup_players
    puts 'Welcome to Chess!'

    print 'Enter Player 1 (White) name: '
    player1_name = gets.chomp
    @players[0].name = player1_name

    print 'Enter Player 2 (Black) name: '
    player2_name = gets.chomp
    @players[1].name = player2_name
    puts
  end

  def get_player_move
    puts 'Enter your move (e.g. , e2 e4)'
    input = gets_chomp.split
    { start: input[0], end: input[1] }
  end

  def display_current_player
    color = @current_player == @players[0] ? 'White' : 'Black'
    puts "#{@current_player.name}'s turn (#{color})"
  end

  def switch_player
    @current_player = @current_player == @players[0] ? @players[1] : @players[0]
  end

  def game_over?
    false
  end

  def check_game_status
  end

  def display_board
    @board.display
  end

  def display_final_result
    puts 'Game Over!'
  end
end
