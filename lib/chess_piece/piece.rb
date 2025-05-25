# frozen_string_literal: true

# Piece class for handling pieces
class Piece
  attr_accessor :moveset, :x, :y, :icon, :color

  def initialize(position, is_white, icon)
    @x = position[0]
    @y = position[1]
    @color = is_white ? 'white' : 'black'
    @icon = icon
  end
end
