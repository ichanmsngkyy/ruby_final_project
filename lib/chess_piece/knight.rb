# frozen_string_literal: true

class Knight < Piece
  def initialize(position, is_white)
    @icon = is_white ? '♘' : '♞'
    super(position, is_white, @icon)
  end

  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)
    return false unless knight_move?(end_pos)

    destination_valid?(end_pos, board)
  end

  private

  def knight_move?(end_pos)
    # Knight moves in L-shape: 2 squares in one direction, 1 in perpendicular
    dx = (end_pos[0] - x).abs
    dy = (end_pos[1] - y).abs
    (dx == 2 && dy == 1) || (dx == 1 && dy == 2)
  end
end
