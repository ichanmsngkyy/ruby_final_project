# frozen_string_literal: true

# Knight class movement
class Knight < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @moveset = [
      [1, 2], [1, -2], [-1, 2], [-1, -2],
      [2, 1], [2, -1], [-2, 1], [-2, -1]
    ]
    @has_moved = false
    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♘' : '♞'
    super(position, is_white, icon)
  end
end
