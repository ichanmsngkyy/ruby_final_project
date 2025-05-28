# frozen_string_literal: true

# Piece class for handling pieces
class Piece
  attr_accessor :moveset, :position, :icon
  attr_reader :color

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

  def path_clear?(end_pos, board)
    raise NotImplementedError, 'This method should be overridden in subclasses'
  end

  def on_board?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def mark_moved!
    @has_moved = true
  end

  def move_to(new_pos)
    @position = new_pos
    mark_moved!
  end
end
