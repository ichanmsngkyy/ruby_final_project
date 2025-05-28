# frozen_string_literal: true

require_relative 'chess_piece/piece'
require_relative 'chess_piece/rook'
require_relative 'chess_piece/bishop'
require_relative 'chess_piece/pawn'
require_relative 'chess_piece/knight'
require_relative 'chess_piece/queen'
require_relative 'chess_piece/king'

# Board class for chess
class Board
  DEFAULT_ROWS = 8
  DEFAULT_COLS = 8

  def initialize
    @grid = Array.new(DEFAULT_ROWS) { Array.new(DEFAULT_COLS, nil) }
    @last_move = nil
  end

  def setup_pieces
    setup_black  # Black pieces on top (rows 0-1)
    setup_white  # White pieces on bottom (rows 6-7)
  end

  def setup_black
    # Black back rank (row 0)
    @grid[0][0] = Rook.new([0, 0], false)
    @grid[0][1] = Knight.new([0, 1], false)
    @grid[0][2] = Bishop.new([0, 2], false)
    @grid[0][3] = Queen.new([0, 3], false)
    @grid[0][4] = King.new([0, 4], false)
    @grid[0][5] = Bishop.new([0, 5], false)
    @grid[0][6] = Knight.new([0, 6], false)
    @grid[0][7] = Rook.new([0, 7], false)

    # Black pawns (row 1)
    (0..7).each { |col| @grid[1][col] = Pawn.new([1, col], false) }
  end

  def setup_white
    # White back rank (row 7)
    @grid[7][0] = Rook.new([7, 0], true)
    @grid[7][1] = Knight.new([7, 1], true)
    @grid[7][2] = Bishop.new([7, 2], true)
    @grid[7][3] = Queen.new([7, 3], true)
    @grid[7][4] = King.new([7, 4], true)
    @grid[7][5] = Bishop.new([7, 5], true)
    @grid[7][6] = Knight.new([7, 6], true)
    @grid[7][7] = Rook.new([7, 7], true)

    # White pawns (row 6)
    (0..7).each { |col| @grid[6][col] = Pawn.new([6, col], true) }
  end

  def display_board
    puts '   A   B   C   D   E   F   G   H'

    @grid.reverse.each_with_index do |row, index|
      # Since we're reversing, row 8 is index 0, row 7 is index 1, ...
      row_number = 8 - index

      print "#{row_number} |"
      row.each do |square|
        # Print piece icon or underscore for nil squares, centered
        print square.nil? ? ' _ ' : " #{square.icon} "
        print '|'
      end
      puts ' '
    end
  end

  def move_piece(start_pos, end_pos)
    piece = self[start_pos]
    return false unless piece

    if piece.valid_move?(end_pos, self)
      if piece.is_a?(Pawn) && en_passant_capture?(piece, end_pos)
        perform_en_passant(piece, end_pos)
      elsif piece.is_a?(King) && castling_move?(piece, end_pos)
        perform_castling(piece, end_pos)
      else
        # Regular move
        self[end_pos] = piece
        self[start_pos] = nil
        piece.move_to(end_pos)
      end

      @last_move = { piece: piece, start_pos: start_pos, end_pos: end_pos }

      # Check for pawn promotion
      promote_pawn(piece) if piece.is_a?(Pawn) && promotion_row?(piece)

      true
    else
      false
    end
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @grid[row][col] = value
  end

  # Add method to get the grid for internal access
  attr_reader :grid

  attr_reader :last_move

  private

  def castling_move?(king, end_pos)
    return false unless king.is_a?(King)

    # Check if it's a castling move (king moves 2 squares horizontally)
    dx = end_pos[0] - king.position[0]
    dy = end_pos[1] - king.position[1]

    dx.zero? && dy.abs == 2
  end

  def perform_castling(king, end_pos)
    # Determine castling side
    king_start = king.position
    queenside = end_pos[1] < king_start[1]

    # Move king
    self[end_pos] = king
    self[king_start] = nil
    king.move_to(end_pos)

    # Move rook
    if queenside
      rook = self[[king_start[0], 0]]
      rook_end = [king_start[0], 3]
    else
      rook = self[[king_start[0], 7]]
      rook_end = [king_start[0], 5]
    end

    self[rook_end] = rook
    self[rook.position] = nil
    rook.move_to(rook_end)
  end

  def en_passant_capture?(pawn, end_pos)
    return false unless pawn.is_a?(Pawn)

    dx = end_pos[0] - pawn.position[0]
    dy = end_pos[1] - pawn.position[1]

    # Must be diagonal move to empty square
    return false unless dx.abs == 1 && dy.abs == 1
    return false unless self[end_pos].nil?

    # Check for enemy pawn that just double-stepped
    captured_pawn_pos = [pawn.position[0], end_pos[1]]
    captured_pawn = self[captured_pawn_pos]

    return false unless captured_pawn.is_a?(Pawn)
    return false unless captured_pawn.color != pawn.color
    return false unless captured_pawn.double_stepped

    # Must be the last move
    @last_move &&
      @last_move[:piece] == captured_pawn &&
      (@last_move[:start_pos][0] - @last_move[:end_pos][0]).abs == 2
  end

  def perform_en_passant(pawn, end_pos)
    # Remove captured pawn
    captured_pawn_pos = [pawn.position[0], end_pos[1]]
    self[captured_pawn_pos] = nil

    # Move attacking pawn
    self[end_pos] = pawn
    self[pawn.position] = nil
    pawn.move_to(end_pos)
  end

  def promotion_row?(pawn)
    (pawn.color == 'white' && pawn.position[0].zero?) ||
      (pawn.color == 'black' && pawn.position[0] == 7)
  end

  def promote_pawn(pawn)
    puts 'Pawn promotion! Choose (Q)ueen, (R)ook, (B)ishop, or K(N)ight:'
    choice = gets.chomp.upcase

    promoted_piece = case choice
                     when 'Q' then Queen.new(pawn.position, pawn.color == 'white')
                     when 'R' then Rook.new(pawn.position, pawn.color == 'white')
                     when 'B' then Bishop.new(pawn.position, pawn.color == 'white')
                     when 'N' then Knight.new(pawn.position, pawn.color == 'white')
                     else
                       puts 'Invalid choice, promoting to Queen by default.'
                       Queen.new(pawn.position, pawn.color == 'white')
                     end
    self[pawn.position] = promoted_piece
  end
end
