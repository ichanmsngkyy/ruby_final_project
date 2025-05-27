# frozen_string_literal: true

# Rook class movement
class Rook < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @moveset = [
      [0, 1], [0, -1], [1, 0], [-1, 0]
    ]
    @has_moved = false
    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♖' : '♜'

    super(position, is_white, icon)
  end
end
