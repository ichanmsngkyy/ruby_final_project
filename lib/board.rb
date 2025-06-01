# frozen_string_literal:true

# Board Class
class Board
  attr_reader :grid

  def initialize
    @grid = (Array.new(8) { Array.new(8) })
  end

  def setup_piece
    white_pieces
    black_pieces
  end
end
