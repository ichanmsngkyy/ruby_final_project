# frozen_string_literal: true

require_relative 'piece'

# King movement Class
class King < Piece
  attr_reader :position, :icon

  def initialize(position, is_white)
    @icon = is_white ? '♔' : '♚'
    super(position, is_white, @icon)
  end

  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)
    return false unless king_move?(end_pos)
    return false unless clear_path?(end_pos, board)

    destination_valid?(end_pos, board)
  end

  private

  # King movement
  def king_move?(end_pos)
    dx = (end_pos[0] - position[0]).abs
    dy = (end_pos[1] - position[1]).abs

    dx <= 1 && dy <= 1 && dx != 0 && dy != 0
  end
end
