# frozen_string_literal: true

# Piece class for handling pieces
class Piece
  attr_accessor :position, :icon
  attr_reader :color, :has_moved

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

  def valid_move?(end_pos, board)
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

  # Clear path check for sliding pieces (rook, bishop, queen)
  def clear_path?(end_pos, board)
    dx = end_pos[0] - x
    dy = end_pos[1] - y

    step_x = dx.zero? ? 0 : dx / dx.abs
    step_y = dy.zero? ? 0 : dy / dy.abs

    curr_x = x + step_x
    curr_y = y + step_y

    while [curr_x, curr_y] != end_pos
      return false unless board[[curr_x, curr_y]].nil?

      curr_x += step_x
      curr_y += step_y
    end

    true
  end

  # Check if destination square is valid (empty or contains enemy piece)
  def destination_valid?(end_pos, board)
    target_piece = board[end_pos]
    target_piece.nil? || target_piece.color != color
  end
end
