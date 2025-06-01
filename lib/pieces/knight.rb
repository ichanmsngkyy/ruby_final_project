# frozen_string_literal: true

require_relative 'piece'

# Knight Class
class Knight < Piece
  attr_reader :position, :icon

  def initialize(position, is_white)
    @icon = is_white ? '♘' : '♞'
    super(position, is_white, @icon)
  end

  # Checking if move is valid
  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)
    return false unless knight_move(end_pos)

    destination_valid?(end_pos, board)
  end

  private

  # Knight movement
  def knight_move(end_pos)
    dx = (end_pos[0] - position[0]).abs
    dy = (end_pos[1] - position[1]).abs

    (dx == 2 && dy == 1) || (dy == 2 && dx == 1)
  end
end
