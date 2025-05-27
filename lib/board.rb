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
  end

  def setup_pieces
    setup_white
    setup_black
  end

  def setup_white
    @grid[0][0] = Rook.new([0, 0], true) # White Rook
    @grid[0][1] = Knight.new([0, 1], true) # White Rook
    @grid[0][2] = Bishop.new([0, 2], true) # White Rook
    @grid[0][3] = Queen.new([0, 3], true) # White Rook
    @grid[0][4] = King.new([0, 4], true) # White Rook
    @grid[0][5] = Bishop.new([0, 5], true) # White Rook
    @grid[0][6] = Knight.new([0, 6], true) # White Rook
    @grid[0][7] = Rook.new([0, 7], true) # White Rook
    (0..7).each { |col| @grid[1][col] = Pawn.new([6, col], true) } # White Pawn
  end

  def setup_black
    @grid[7][0] = Rook.new([7, 0], false) # Black Rook
    @grid[7][1] = Knight.new([7, 1], false) # Black Knight
    @grid[7][2] = Bishop.new([7, 2], false) # Black Bishop
    @grid[7][3] = Queen.new([7, 3], false) # Black Queen
    @grid[7][4] = King.new([7, 4], false) # Black King
    @grid[7][5] = Bishop.new([7, 5], false) # Black Bishop
    @grid[7][6] = Knight.new([7, 6], false) # Black Knight
    @grid[7][7] = Rook.new([7, 7], false) # Black Rook
    (0..7).each { |col| @grid[6][col] = Pawn.new([6, col], false) } # Black Pawn
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
      self[end_pos] = piece
      self[start_pos] = nil
      piece.position = end_pos
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
end
