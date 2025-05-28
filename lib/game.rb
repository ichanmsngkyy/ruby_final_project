# frozen_string_literal: true

require 'json'
require_relative 'board'
require_relative 'save_file'
class Game
  attr_reader :board, :current_player, :players, :game_state, :move_history

  def initialize(player1_name = 'Player 1', player2_name = 'Player 2', ai_difficulty = nil)
    @board = Board.new
    @board.setup_pieces

    # Setup players
    @players = if ai_difficulty
                 [
                   Player.new(player1_name, 'white'),
                   AIPlayer.new(player2_name, 'black', ai_difficulty)
                 ]
               else
                 [
                   Player.new(player1_name, 'white'),
                   Player.new(player2_name, 'black')
                 ]
               end

    @current_player = @players[0] # White starts
    @game_state = :active
    @move_history = []
    @move_count = 0
  end

  def play
    puts 'Starting new chess game!'
    puts "#{@players[0].name} (White) vs #{@players[1].name} (Black)"
    puts "Type 'save' to save the game or 'exit' to quit"
    puts

    while @game_state == :active
      @board.display_board
      puts
      puts "Move #{@move_count + 1}"

      move = @current_player.get_move(@board)

      # Handle special commands
      case move
      when :save
        handle_save_command
        next
      when :exit
        handle_exit_command
        break
      end

      if move && valid_move?(move)
        execute_move(move)
        check_game_end
        switch_players unless @game_state != :active
      else
        puts 'Invalid move! Try again.'
      end
    end

    display_game_result unless move == :exit
  end

  def handle_save_command
    puts 'Enter filename to save (without extension):'
    filename = gets.chomp.strip

    filename = "chess_save_#{Time.now.strftime('%Y%m%d_%H%M%S')}" if filename.empty?

    return unless save_game(filename)

    puts "Game saved! You can continue playing or type 'exit' to quit."
  end

  def handle_exit_command
    puts 'Do you want to save before exiting? (y/n)'
    response = gets.chomp.strip.downcase

    handle_save_command if %w[y yes].include?(response)

    puts 'Thanks for playing! Goodbye.'
  end

  def save_game(filename)
    SaveFile.save_game(self, filename)
  end

  def self.load_game(filename)
    SaveFile.load_game(filename)
  end

  def to_hash
    {
      board_state: serialize_board,
      current_player_index: @players.index(@current_player),
      players: @players.map { |p| serialize_player(p) },
      game_state: @game_state,
      move_history: @move_history,
      move_count: @move_count
    }
  end

  def self.from_hash(hash)
    game = allocate
    game.send(:initialize_from_hash, hash)
    game
  end

  private

  def valid_move?(move)
    return false unless move

    start_pos, end_pos = move
    piece = @board[start_pos]

    return false unless piece
    return false unless piece.color == @current_player.color

    piece.valid_move?(end_pos, @board)
  end

  def execute_move(move)
    start_pos, end_pos = move
    piece = @board[start_pos]

    # Record move in history
    @move_history << {
      move_number: @move_count + 1,
      player: @current_player.name,
      piece: piece.class.name,
      from: coords_to_algebraic(start_pos),
      to: coords_to_algebraic(end_pos),
      captured: @board[end_pos]&.class&.name
    }

    @board.move_piece(start_pos, end_pos)
    @move_count += 1
  end

  def switch_players
    @current_player = @current_player == @players[0] ? @players[1] : @players[0]
  end

  def check_game_end
    if checkmate?
      @game_state = :checkmate
    elsif stalemate?
      @game_state = :stalemate
    end
  end

  def checkmate?
    # Simplified checkmate detection
    king = find_king(@current_player.color)
    return false unless king

    in_check?(king) && no_valid_moves?
  end

  def stalemate?
    # Simplified stalemate detection
    king = find_king(@current_player.color)
    return false unless king

    !in_check?(king) && no_valid_moves?
  end

  def find_king(color)
    @board.grid.each do |row|
      row.each do |piece|
        return piece if piece.is_a?(King) && piece.color == color
      end
    end
    nil
  end

  def in_check?(king)
    # Simplified check detection
    king_pos = king.position

    @board.grid.each_with_index do |row, _row_idx|
      row.each_with_index do |piece, _col_idx|
        next unless piece && piece.color != king.color

        return true if piece.valid_move?(king_pos, @board)
      end
    end

    false
  end

  def no_valid_moves?
    @board.grid.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        next unless piece && piece.color == @current_player.color

        start_pos = [row_idx, col_idx]

        (0..7).each do |end_row|
          (0..7).each do |end_col|
            end_pos = [end_row, end_col]
            next if start_pos == end_pos

            return false if piece.valid_move?(end_pos, @board)
          end
        end
      end
    end

    true
  end

  def display_game_result
    case @game_state
    when :checkmate
      winner = @current_player == @players[0] ? @players[1] : @players[0]
      puts "Checkmate! #{winner.name} wins!"
    when :stalemate
      puts 'Stalemate! The game is a draw.'
    end
  end

  def coords_to_algebraic(coords)
    row, col = coords
    "#{('a'.ord + col).chr}#{8 - row}"
  end

  def serialize_board
    @board.grid.map do |row|
      row.map do |piece|
        next nil unless piece

        {
          class: piece.class.name,
          position: piece.position,
          color: piece.color,
          has_moved: piece.has_moved,
          double_stepped: piece.respond_to?(:double_stepped) ? piece.double_stepped : nil
        }
      end
    end
  end

  def serialize_player(player)
    data = {
      name: player.name,
      color: player.color,
      type: player.type
    }
    data[:difficulty] = player.difficulty if player.is_a?(AIPlayer)
    data
  end

  def initialize_from_hash(hash)
    @board = Board.new
    deserialize_board(hash[:board_state])

    @players = hash[:players].map { |p_data| deserialize_player(p_data) }
    @current_player = @players[hash[:current_player_index]]
    @game_state = hash[:game_state].to_sym
    @move_history = hash[:move_history]
    @move_count = hash[:move_count]
  end

  def deserialize_board(board_state)
    board_state.each_with_index do |row, row_idx|
      row.each_with_index do |piece_data, col_idx|
        next unless piece_data

        piece_class = Object.const_get(piece_data[:class])
        is_white = piece_data[:color] == 'white'
        piece = piece_class.new(piece_data[:position], is_white)

        piece.instance_variable_set(:@has_moved, piece_data[:has_moved])
        if piece.respond_to?(:double_stepped) && piece_data[:double_stepped]
          piece.instance_variable_set(:@double_stepped, piece_data[:double_stepped])
        end

        @board.grid[row_idx][col_idx] = piece
      end
    end
  end

  def deserialize_player(player_data)
    if player_data[:type] == 'ai'
      AIPlayer.new(player_data[:name], player_data[:color], player_data[:difficulty].to_sym)
    else
      Player.new(player_data[:name], player_data[:color])
    end
  end
end
