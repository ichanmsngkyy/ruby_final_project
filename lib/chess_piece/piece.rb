# frozen_string_literal: true

# Piece class for handling pieces
class Piece
  attr_accessor :moveset, :position, :icon, :color

  def initialize(position, is_white, icon)
    @position = position
    @color = is_white ? 'white' : 'black'
    @icon = icon
  end

  def x
    @position[0]
  end

  def y
    @position[1]
  end

  def valid_move?(end_pos, board)
    raise NotImplementedError, 'This method should be overridden in subclasses'
  end
end
