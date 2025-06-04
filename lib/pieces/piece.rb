# frozen_string_literal: true

# frozen_string_literal : true

# Piece superclass
class Piece
  attr_accessor :position, :has_moved
  attr_reader :color, :icon

  def initialize(position, is_white, icon)
    @position = position
    @color = is_white ? 'white' : 'black'
    @icon = icon
    @has_moved = false
  end

  def x
    @position[0]
  end

  def y
    @position[1]
  end

  # Abstract Valid move
  def valid_move?(end_pos, board)
    raise NotImplementedError, 'This method should be overridden in subclasses'
  end

  # Checking if the piece has been moved
  def mark_moved!
    @has_moved = true
  end

  # Validating if the position is inside the board
  def on_board?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  # Checking if the path is clear
  def clear_path?(end_pos, board)
    dx = end_pos[0] - position[0] # Changed from 'x' to 'position[0]'
    dy = end_pos[1] - position[1]  # Changed from 'y' to 'position[1]'

    step_x = dx.zero? ? 0 : dx / dx.abs
    step_y = dy.zero? ? 0 : dy / dy.abs

    curr_x = position[0] + step_x  # Changed from 'x' to 'position[0]'
    curr_y = position[1] + step_y  # Changed from 'y' to 'position[1]'

    while curr_x != end_pos[0] || curr_y != end_pos[1]
      return false unless board[[curr_x, curr_y]].nil?

      curr_x += step_x
      curr_y += step_y
    end

    true
  end

  # To check if the destination is clear
  def destination_valid?(end_pos, board)
    target_piece = board[end_pos]
    target_piece.nil? || target_piece.color != color
  end
end
