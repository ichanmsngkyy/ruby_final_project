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

  def setup_piece
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
    @grid[1][0] = Pawn.new([1, 0], true) # White Pawn
    @grid[1][1] = Pawn.new([1, 1], true) # White Pawn
    @grid[1][2] = Pawn.new([1, 2], true) # White Pawn
    @grid[1][3] = Pawn.new([1, 3], true) # White Pawn
    @grid[1][4] = Pawn.new([1, 4], true) # White Pawn
    @grid[1][5] = Pawn.new([1, 5], true) # White Pawn
    @grid[1][6] = Pawn.new([1, 6], true) # White Pawn
    @grid[1][7] = Pawn.new([1, 7], true) # White Pawn
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
    @grid[6][0] = Pawn.new([6, 0], false) # Black Pawn
    @grid[6][1] = Pawn.new([6, 1], false) # Black Pawn
    @grid[6][2] = Pawn.new([6, 2], false) # Black Pawn
    @grid[6][3] = Pawn.new([6, 3], false) # Black Pawn
    @grid[6][4] = Pawn.new([6, 4], false) # Black Pawn
    @grid[6][5] = Pawn.new([6, 5], false) # Black Pawn
    @grid[6][6] = Pawn.new([6, 6], false) # Black Pawn
    @grid[6][7] = Pawn.new([6, 7], false) # Black Pawn
  end

  def display_board
    column_labels = '   A   B   C   D   E   F   G   H'
    puts column_labels

    @grid.each_with_index do |row, index|
      print "#{(8 - index).to_s.strip} |" # Ensure the number uses only two spaces
      puts row.map { |square| square.nil? ? ' _ ' : square.icon.center(3) }.join('|') + ' |'
    end
  end
end
