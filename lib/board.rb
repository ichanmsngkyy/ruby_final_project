# frozen_string_literal: true

# Board class for chess
class Board
  DEFAULT_ROWS = 8
  DEFAULT_COLS = 8

  def initialize
    @grid = Array.new(DEFAULT_ROWS) { Array.new(DEFAULT_COL, nil) }
    setup_piece
  end

  def setup_piece
    @grid[0][7] = Rook.new(:black)
    @grid[0][1] = Rook.new(:white)
  end

  def display_board
    @grid.each do |row|
      puts row.map { |square| square.nil? ? '_' : square.symbol }.join(' ')
    end
  end
end
