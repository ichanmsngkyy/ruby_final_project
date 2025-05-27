# frozen_string_literal: true

require_relative 'lib/board'
require_relative 'lib/chess_piece/piece'
require_relative 'lib/chess_piece/rook'
require_relative 'lib/chess_piece/bishop'
require_relative 'lib/chess_piece/pawn'
require_relative 'lib/chess_piece/knight'
require_relative 'lib/chess_piece/queen'
require_relative 'lib/chess_piece/king'

# Main class
class Main
  board = Board.new
  board.setup_piece
  board.display_board
end
