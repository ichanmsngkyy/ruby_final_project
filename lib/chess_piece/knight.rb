# frozen_string_literal: true

# Knight class movement
class Knight < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @moveset = [
      [1, 2], [1, -2], [-1, 2], [-1, -2],
      [2, 1], [2, -1], [-2, 1], [-2, -1]
    ]
    @has_moved = false
    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♘' : '♞'
    super(position, is_white, icon)
  end

  def valid_move?(end_pos, board)
    return false unless knight_move(end_pos)

    dest_piece = board[end_pos[0]][end_pos[1]]
    return false if dest_piece && dest_piece.color == color

    true
  end

  private

  def knight_move(end_pos)
    (end_pos[0] - x).abs == 2 && (end_pos[1] - y).abs == 1 ||
      (end_pos[0] - x).abs == 1 && (end_pos[1] - y).abs == 2
  end
end
