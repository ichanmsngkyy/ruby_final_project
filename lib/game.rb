# frozen_string_literal: true

require_relative 'board'
require_relative 'pieces/piece'
require_relative 'pieces/rook'
require_relative 'pieces/bishop'
require_relative 'pieces/knight'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'
require_relative 'player'
require_relative 'AIplayer'
require_relative 'player_factory'
require 'json'

# Game Class File
class Game
  attr_reader :board, :current_player, :players, :game_status

  def initialize
    # Use factory to set up players instead of passing them in
    @players = PlayerFactory.setup_game_players
    @current_player = @players[0]
    @game_status = :in_progress
    @board = Board.new
    @move_history = []
  end

  def play
    puts "#{@players[0].name} (White) vs #{@players[1].name} (Black)"
    puts "Let's Begin!"
    puts "Type 'save' to save the game, 'help' for commands" if any_human_players?
    puts

    until game_over?
      display_board
      display_current_player

      if @current_player.ai?
        handle_ai_turn
      else
        handle_human_turn
      end
    end
    display_final_result
  end

  def make_move(start_pos, end_pos)
    start_coords = convert_notation(start_pos)
    end_coords = convert_notation(end_pos)

    return false unless valid_coordinates?(start_coords) && valid_coordinates?(end_coords)

    piece = @board[start_coords]
    return false if piece.nil?

    return false unless piece.color == @current_player.color

    return false unless @board.move_piece(start_coords, end_coords)

    if @board.in_check?(@current_player.color)
      undo_last_move(start_coords, end_coords)
      return false
    end

    true
  end

  def make_move_from_coords(start_coords, end_coords)
    return false unless valid_coordinates?(start_coords) && valid_coordinates?(end_coords)

    piece = @board[start_coords]
    return false if piece.nil?

    return false unless piece.color == @current_player.color

    return false unless @board.move_piece(start_coords, end_coords)

    if @board.in_check?(@current_player.color)
      undo_last_move(start_coords, end_coords)
      return false
    end

    true
  end

  def save_game(filename = nil)
    filename ||= "chess_save_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json"

    game_data = {
      board_state: serialize_board,
      current_player_index: @players.index(@current_player),
      players: serialize_players,
      game_status: @game_status,
      move_history: @move_history
    }

    begin
      File.write(filename, JSON.pretty_generate(game_data))
      puts "Game saved successfully as #{filename}"
      filename
    rescue StandardError => e
      puts "Error saving game: #{e.message}"
      nil
    end
  end

  def load_game(filename)
    unless File.exist?(filename)
      puts "Save file '#{filename}' not found!"
      return false
    end

    begin
      game_data = JSON.parse(File.read(filename))

      restore_board(game_data['board_state'])
      restore_players(game_data['players'])

      @current_player = @players[game_data['current_player_index']]
      @game_status = game_data['game_status'].to_sym
      @move_history = game_data['move_history'] || []

      puts "Game loaded successfully from #{filename}"
      puts "#{@players[0].name} (White) vs #{@players[1].name} (Black)"
      true
    rescue JSON::ParserError
      puts 'Error: Invalid save file format!'
      false
    rescue StandardError => e
      puts "Error loading game: #{e.message}"
      false
    end
  end

  def list_save_files
    save_files = Dir.glob('chess_save_*.json').sort.reverse

    if save_files.empty?
      puts 'No save files found.'
      return []
    end

    puts 'Available save files:'
    save_files.each_with_index do |file, index|
      file_time = File.mtime(file).strftime('%Y-%m-%d %H:%M:%S')
      puts "#{index + 1}. #{file} (#{file_time})"
    end

    save_files
  end

  private

  def any_human_players?
    @players.any?(&:human?)
  end

  def handle_ai_turn
    puts "#{@current_player.name} is thinking..."

    ai_move = @current_player.get_move(@board)

    if ai_move && make_move_from_coords(ai_move[:start], ai_move[:end])
      start_notation = coords_to_notation(ai_move[:start])
      end_notation = coords_to_notation(ai_move[:end])

      puts "#{@current_player.name} moves: #{start_notation} to #{end_notation}"
      record_move(start_notation, end_notation)
      display_board
      check_game_status
      switch_player unless game_over?

      # Add delay so humans can follow AI moves
      sleep(1.5) if any_human_players?
    else
      puts "#{@current_player.name} has no legal moves!"
      @game_status = @current_player.color == 'white' ? :black_wins : :white_wins
    end
  end

  def handle_human_turn
    input = get_player_input

    case input[:type]
    when :move
      if make_move(input[:start], input[:end])
        record_move(input[:start], input[:end])
        display_board
        check_game_status
        switch_player unless game_over?
      else
        puts 'Invalid move! Try Again'
        puts
      end
    when :save
      save_game(input[:filename])
    when :help
      show_help
    when :quit
      puts 'Thanks for playing!'
      exit
    end
  end

  def serialize_players
    @players.map do |player|
      {
        name: player.name,
        color: player.color,
        type: player.type,
        difficulty: player.respond_to?(:difficulty) ? player.instance_variable_get(:@difficulty) : nil
      }
    end
  end

  def restore_players(players_data)
    @players = players_data.map do |player_data|
      if player_data['type'] == 'ai'
        AIPlayer.new(player_data['name'], player_data['color'], player_data['difficulty']&.to_sym || :easy)
      else
        HumanPlayer.new(player_data['name'], player_data['color'])
      end
    end
  end

  def coords_to_notation(coords)
    row, col = coords
    "#{('a'.ord + col).chr}#{row + 1}"
  end

  def show_main_menu
    puts 'Welcome to Chess!'
    puts '1. New Game'
    puts '2. Load Game'
    puts '3. Quit'
    print 'Choose an option (1-3): '

    choice = gets.chomp

    case choice
    when '1'
      true
    when '2'
      handle_load_game
    when '3'
      puts 'Goodbye!'
      exit
    else
      puts 'Invalid choice. Starting new game...'
      true
    end
  end

  def handle_load_game
    save_files = list_save_files
    return true if save_files.empty? # Start new game if no saves

    print "Enter the number of the save file to load (or 'new' for new game): "
    choice = gets.chomp.downcase

    if choice == 'new'
      true
    elsif choice.match?(/^\d+$/)
      index = choice.to_i - 1
      return !load_game(save_files[index]) if index >= 0 && index < save_files.length

      puts 'Invalid selection. Starting new game...'
      true
    else
      puts 'Invalid input. Starting new game...'
      true
    end
  end

  def get_player_input
    print '> '
    input = gets.chomp.downcase.strip

    case input
    when 'save'
      print 'Enter filename (or press Enter for auto-name): '
      filename = gets.chomp
      filename = nil if filename.empty?
      { type: :save, filename: filename }
    when 'help'
      { type: :help }
    when 'quit', 'exit'
      { type: :quit }
    else
      parts = input.split
      if parts.length == 2
        { type: :move, start: parts[0], end: parts[1] }
      else
        puts "Invalid input! Enter move like 'e2 e4', or 'save', 'help', 'quit'"
        get_player_input
      end
    end
  end

  def show_help
    puts "\nCommands:"
    puts '  Move: e2 e4 (from square to square)'
    puts '  Save: save'
    puts '  Help: help'
    puts '  Quit: quit'
    puts "\nMove notation: Use algebraic notation (a1-h8)"
    puts
  end

  def record_move(start_pos, end_pos)
    @move_history << {
      from: start_pos,
      to: end_pos,
      player: @current_player.color,
      player_name: @current_player.name,
      timestamp: Time.now
    }
  end

  def serialize_board
    board_data = []
    (0..7).each do |row|
      (0..7).each do |col|
        piece = @board[[row, col]]
        next unless piece

        board_data << {
          position: [row, col],
          type: piece.class.name,
          color: piece.color,
          has_moved: piece.has_moved
        }
      end
    end
    board_data
  end

  def restore_board(board_data)
    @board = Board.new
    (0..7).each do |row|
      (0..7).each do |col|
        @board[[row, col]] = nil
      end
    end

    board_data.each do |piece_data|
      position = piece_data['position']
      piece_type = piece_data['type']
      color = piece_data['color']
      has_moved = piece_data['has_moved']

      piece = case piece_type
              when 'Pawn'
                Pawn.new(position, color == 'white')
              when 'Rook'
                Rook.new(position, color == 'white')
              when 'Knight'
                Knight.new(position, color == 'white')
              when 'Bishop'
                Bishop.new(position, color == 'white')
              when 'Queen'
                Queen.new(position, color == 'white')
              when 'King'
                King.new(position, color == 'white')
              end

      if piece
        piece.has_moved = has_moved
        @board[position] = piece
      end
    end
  end

  def check_game_status
    if checkmate?(@current_player.color)
      winner_color = @current_player.color == 'white' ? 'black' : 'white'
      @game_status = winner_color == 'white' ? :white_wins : :black_wins
      puts "Checkmate! #{winner_color.capitalize} wins!"
    elsif stalemate?(@current_player.color)
      @game_status = :stalemate
      puts "Stalemate! It's a draw!"
    elsif @board.in_check?(@current_player.color)
      puts 'Check!'
    end
  end

  def display_board
    @board.display
  end

  def display_current_player
    puts "#{@current_player.name}'s turn (#{@current_player.color.capitalize})"
  end

  def display_final_result
    case @game_status
    when :white_wins
      puts "Game Over! #{@players[0].name} (White) wins by checkmate!"
    when :black_wins
      puts "Game Over! #{@players[1].name} (Black) wins by checkmate!"
    when :stalemate
      puts "Game Over! It's a draw by stalemate!"
    else
      puts 'Game Over!'
    end
  end

  def switch_player
    @current_player = @current_player == @players[0] ? @players[1] : @players[0]
  end

  def game_over?
    checkmate?(@current_player.color) || stalemate?(@current_player.color)
  end

  def convert_notation(notation)
    return notation if notation.is_a?(Array)

    col = notation[0].ord - 'a'.ord
    row = notation[1].to_i - 1
    [row, col]
  end

  def valid_coordinates?(coords)
    coords.all? { |coord| coord.between?(0, 7) }
  end

  def undo_last_move(start_pos, end_pos)
    piece = @board[end_pos]
    @board[start_pos] = piece
    @board[end_pos] = nil
    piece.position = start_pos if piece
  end

  def checkmate?(color)
    @board.in_check?(color) && no_legal_moves?(color)
  end

  def stalemate?(color)
    !@board.in_check?(color) && no_legal_moves?(color)
  end

  def no_legal_moves?(color)
    (0..7).each do |row|
      (0..7).each do |col|
        piece = @board[[row, col]]

        next if piece.nil? || piece.color != color

        (0..7).each do |target_row|
          (0..7).each do |target_col|
            target_pos = [target_row, target_col]
            next if [row, col] == target_pos

            return false if piece.valid_move?(target_pos, @board) && legal_move?([row, col], target_pos, color)
          end
        end
      end
    end
    true
  end

  def legal_move?(start_pos, end_pos, color)
    original_piece = @board[end_pos]
    piece = @board[start_pos]

    @board[end_pos] = piece
    @board[start_pos] = nil
    piece.position = end_pos if piece

    king_safe = !@board.in_check?(color)

    @board[start_pos] = piece
    @board[end_pos] = original_piece
    piece.position = start_pos if piece

    king_safe
  end
end
