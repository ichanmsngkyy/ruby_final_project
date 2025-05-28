# frozen_string_literal: true

class Queen < Piece
  def initialize(position, is_white)
    @icon = is_white ? '♕' : '♛'
    super(position, is_white, @icon)
  end

  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)
    return false unless queen_move?(end_pos)
    return false unless clear_path?(end_pos, board)

    destination_valid?(end_pos, board)
  end

  private

  def queen_move?(end_pos)
    # Queen moves like rook or bishop
    dx = (end_pos[0] - x).abs
    dy = (end_pos[1] - y).abs

    # Horizontal, vertical, or diagonal movement
    (dx.zero? && dy.positive?) || (dy.zero? && dx.positive?) || (dx == dy && dx.positive?)
  end
end
