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
    @players = []
    @current_player = nil
    @game_status = :in_progress
    @board = Board.new
    @move_history = []
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
      setup_new_game
      play
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

  def setup_new_game
    @players = PlayerFactory.setup_game_players
    @current_player = @players[0]
    @game_status = :in_progress
    @board = Board.new
    @move_history = []
    true
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
    # Check for castling notation first
    return handle_castle_move(start_pos, end_pos) if castle_notation?(start_pos, end_pos)

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

  def save_game(filename = nil)
    filename ||= "chess_save_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
    filename += '.json' unless filename.end_with?('.json')

    game_data = {
      board_state: serialize_board,
      current_player_index: @players.index(@current_player),
      players: serialize_players,
      game_status: @game_status,
      move_history: @move_history
    }

    begin
      # Create saves directory if it doesn't exist
      saves_dir = 'saves'
      Dir.mkdir(saves_dir) unless Dir.exist?(saves_dir)

      # Save to the saves directory
      save_path = File.join(saves_dir, filename)
      File.write(save_path, JSON.pretty_generate(game_data))

      # Verify the file was created
      if File.exist?(save_path)
        file_size = File.size(save_path)
        puts "Game saved successfully as #{save_path} (#{file_size} bytes)"
        puts "Current directory: #{Dir.pwd}"
        save_path
      else
        puts "Error: File was not created at #{save_path}"
        nil
      end
    rescue StandardError => e
      puts "Error saving game: #{e.message}"
      puts "Error class: #{e.class}"
      puts "Current directory: #{Dir.pwd}"
      puts "Directory writable? #{File.writable?(Dir.pwd)}"
      nil
    end
  end

  def load_game(filename)
    # Handle both full paths and just filenames
    save_path = if filename.include?('saves/')
                  filename
                else
                  File.join('saves', File.basename(filename))
                end

    # Also try the original filename in current directory for backward compatibility
    paths_to_try = [save_path, filename].uniq

    file_found = nil
    paths_to_try.each do |path|
      if File.exist?(path)
        file_found = path
        break
      end
    end

    unless file_found
      puts 'Save file not found!'
      puts 'Tried paths:'
      paths_to_try.each { |path| puts "  - #{File.expand_path(path)}" }
      return false
    end

    begin
      game_data = JSON.parse(File.read(file_found))

      restore_board(game_data['board_state'])
      restore_players(game_data['players'])

      @current_player = @players[game_data['current_player_index']]
      @game_status = game_data['game_status'].to_sym
      @move_history = game_data['move_history'] || []

      puts "Game loaded successfully from #{file_found}"
      puts "#{@players[0].name} (White) vs #{@players[1].name} (Black)"
      play
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
    saves_dir = File.expand_path('../saves/*.json', __dir__)
    puts saves_dir
    pattern = File.join(saves_dir)
    save_files = Dir.glob(pattern).sort_by { |f| File.mtime(f) }.reverse

    if save_files.empty?
      puts 'No save files found.'
      puts "Checked directory: #{saves_dir}"
      return []
    end

    puts 'Available save files:'
    save_files.each_with_index do |file, index|
      filename = File.basename(file)
      file_time = File.mtime(file).strftime('%Y-%m-%d %H:%M:%S')
      puts "#{index + 1}. #{filename} (#{file_time})"
    end

    save_files
  end

  private

  def coords_to_notation(coords)
    row, col = coords
    "#{('a'.ord + col).chr}#{row + 1}"
  end

  def handle_load_game
    save_files = list_save_files

    if save_files.empty?
      puts 'No save files found. Starting new game...'
      setup_new_game
      return
    end

    puts "\nYou can either:"
    puts '1. Enter a filename directly'
    puts '2. Enter a number to select from the list above'
    puts "3. Type 'new' for a new game"

    print "\nEnter your choice: "
    choice = gets.chomp.strip

    if choice.downcase == 'new'
      setup_new_game
    elsif choice.match?(/^\d+$/)
      # User entered a number - treat as index
      index = choice.to_i - 1

      if index >= 0 && index < save_files.length
        selected_file = save_files[index]
        filename = File.basename(selected_file)

        puts "Loading file: #{filename}"

        return true if load_game(filename)

        puts "Failed to load '#{filename}'"
      else
        puts "Invalid selection. Please choose a number between 1 and #{save_files.length}"
      end

      # Offer to try again or start new game
      print 'Would you like to try another selection? (y/n): '
      retry_choice = gets.chomp.downcase

      if %w[y yes].include?(retry_choice)
        handle_load_game # Recursive call to try again
      else
        puts 'Starting new game...'
        setup_new_game
      end
    else
      # User entered a filename directly
      filename = choice

      # Add .json extension if not present
      filename += '.json' unless filename.end_with?('.json')

      puts "Attempting to load file: #{filename}"

      return true if load_game(filename)

      puts "Failed to load '#{filename}'"

      # Offer to try again or start new game
      print 'Would you like to try another filename? (y/n): '
      retry_choice = gets.chomp.downcase

      if %w[y yes].include?(retry_choice)
        handle_load_game # Recursive call to try again
      else
        puts 'Starting new game...'
        setup_new_game
      end
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
    when 'o-o', '0-0'
      { type: :move, start: 'o-o', end: nil }
    when 'o-o-o', '0-0-0'
      { type: :move, start: 'o-o-o', end: nil }
    else
      parts = input.split
      if parts.length == 2
        { type: :move, start: parts[0], end: parts[1] }
      elsif parts.length == 1 && ['o-o', 'o-o-o', '0-0', '0-0-0'].include?(parts[0])
        { type: :move, start: parts[0], end: nil }
      else
        puts "Invalid input! Enter move like 'e2 e4', 'o-o' for kingside castle, 'o-o-o' for queenside castle, or 'save', 'help', 'quit'"
        get_player_input
      end
    end
  end

  def castle_notation?(start_pos, end_pos)
    # Check for standard castling notation
    (start_pos.downcase == 'o-o' && end_pos.nil?) || # Kingside castling
      (start_pos.downcase == 'o-o-o' && end_pos.nil?) ||  # Queenside castling
      (start_pos.downcase == '0-0' && end_pos.nil?) ||    # Alternative kingside
      (start_pos.downcase == '0-0-0' && end_pos.nil?)     # Alternative queenside
  end

  def handle_castle_move(notation, _end_pos = nil)
    side = if notation.downcase.include?('o-o-o') || notation.downcase.include?('0-0-0')
             'queenside'
           else
             'kingside'
           end

    return false unless @board.can_castle?(@current_player.color, side)

    execute_castle(@current_player.color, side)
    true
  end

  def execute_castle(color, side)
    king_start = color == 'white' ? [0, 4] : [7, 4]

    if side == 'kingside'
      king_end = color == 'white' ? [0, 6] : [7, 6]
      rook_start = color == 'white' ? [0, 7] : [7, 7]
      rook_end = color == 'white' ? [0, 5] : [7, 5]
    else # queenside
      king_end = color == 'white' ? [0, 2] : [7, 2]
      rook_start = color == 'white' ? [0, 0] : [7, 0]
      rook_end = color == 'white' ? [0, 3] : [7, 3]
    end

    # Move king
    king = @board[king_start]
    @board[king_start] = nil
    @board[king_end] = king
    king.position = king_end
    king.mark_moved!

    # Move rook
    rook = @board[rook_start]
    @board[rook_start] = nil
    @board[rook_end] = rook
    rook.position = rook_end
    rook.mark_moved!

    puts "#{@current_player.name} castles #{side}!"
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

  def show_help
    puts "\nCommands:"
    puts '  Move: e2 e4 (from square to square)'
    puts '  Kingside Castle: o-o or 0-0'
    puts '  Queenside Castle: o-o-o or 0-0-0'
    puts '  Save: save'
    puts '  Help: help'
    puts '  Quit: quit'
    puts "\nMove notation: Use algebraic notation (a1-h8)"
    puts 'Castling: King and rook must not have moved, no pieces between them,'
    puts "          king not in check, and king doesn't move through check"
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

  def any_human_players?
    @players.any?(&:human?)
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

  def handle_ai_turn
    puts "#{@current_player.name} is thinking..."

    ai_move = @current_player.get_move(@board)

    if ai_move && make_move_from_coords(ai_move[:start], ai_move[:end])
      start_notation = coords_to_notation(ai_move[:start])
      end_notation = coords_to_notation(ai_move[:end])

      puts "#{@current_player.name} moves: #{start_notation} to #{end_notation}"
      record_move(start_notation, end_notation)
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
        check_game_status
        switch_player unless game_over?
      else
        puts 'Invalid move! Try Again'
        puts
      end
    when :save
      save_game(input[:filename])
      exit
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
