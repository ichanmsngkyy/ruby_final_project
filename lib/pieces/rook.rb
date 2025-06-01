# frozen_string_literal: true

require_relative 'piece'

# Rook Class
# Inherits of Piece
class Rook < Piece
  attr_reader :position, :icon

  def initialize(position, is_white)
    @icon = is_white ? '♖' : '♜'
    super(position, is_white, @icon)
  end

  # Checking if move is valid
  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)
    return false unless rook_move(end_pos)
    return false unless clear_path?(end_pos, board)

    destination_valid?(end_pos, board)
  end

  private

  # Rook movement
  def rook_move(end_pos)
    dx = (end_pos[0] - position[0]).abs
    dy = (end_pos[1] - position[1]).abs
    (dx.zero? && dy != 0) || (dy.zero? && dx != 0)
  end
end
