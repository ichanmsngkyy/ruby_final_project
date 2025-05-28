# frozen_string_literal: true

class Bishop < Piece
  def initialize(position, is_white)
    @icon = is_white ? '♗' : '♝'
    super(position, is_white, @icon)
  end

  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)
    return false unless diagonal_move?(end_pos)
    return false unless clear_path?(end_pos, board)

    destination_valid?(end_pos, board)
  end

  private

  def diagonal_move?(end_pos)
    # Bishop moves diagonally only
    dx = (end_pos[0] - x).abs
    dy = (end_pos[1] - y).abs
    dx == dy && dx.positive?
  end
end
