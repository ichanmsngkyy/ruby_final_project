# frozen_string_literal: true

# Bishop class movement
class Bishop < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @moveset = [
      [1, 1], [1, -1], [-1, 1], [-1, -1]
    ]
    @has_moved = false
    icon = is_white ? '♗' : '♝'
    super(position, is_white, icon)
  end

  def valid_move?(end_pos, board)
    return false unless diagonal_move?(end_pos)
    return false unless path_clear?(end_pos, board)

    dest_piece = board[end_pos[0]][end_pos[1]]
    return false if dest_piece && dest_piece.color == color

    true
  end

  private

  def diagonal_move?(end_pos)
    (end_pos[0] - x).abs == (end_pos[1] - y).abs
  end

  def path_clear?(end_pos, board)
    step_row = (end_pos[0] - x).positive? ? 1 : -1
    step_col = (end_pos[1] - y).positive? ? 1 : -1

    current_row = x + step_row
    current_col = y + step_col

    while current_row != end_pos[0] && current_col != end_pos[1]
      return false unless board[current_row][current_col].nil?

      current_row += step_row
      current_col += step_col
    end

    true
  end
end
