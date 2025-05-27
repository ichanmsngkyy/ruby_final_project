# frozen_string_literal: true

# Pawn class movement
class Pawn < Piece
  attr_reader :has_moved, :double_stepped

  def initialize(position, is_white)
    @moveset = {
      one_step: [1, 0],
      double_step: [2, 0],
      right_diagonal: [1, 1],
      left_diagonal: [1, -1]
    }

    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♙' : '♟'
    @position = position
    @has_moved = false
    @double_stepped = false
    super(position, is_white, icon)
    @moveset.each_key { |move_type| @moveset[move_type][0] *= -1 } if is_white
  end
end
