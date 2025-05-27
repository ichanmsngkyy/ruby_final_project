# frozen_string_literal: true

# Queen class movements
class Queen < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @moveset = [
      [0, 1], [0, -1], [1, 0], [-1, 0],
      [1, 1], [1, -1], [-1, 1], [-1, -1]
    ]
    @has_moved = false
    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♕' : '♛'
    super(position, is_white, icon)
  end
end
