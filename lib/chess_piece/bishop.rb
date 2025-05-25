# frozen_string_literal: true

# Bishop class movement
class Bishop < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @moveset = [
      [1, 1], [1, -1], [-1, 1], [-1, -1]
    ]
    @has_moved = false
    @color = is_white ? '♗' : '♝'
    super(position, is_white, icon)
  end
end
