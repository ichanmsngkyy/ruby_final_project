# frozen_string_literal: true

# Bishop class movement
class Bishop < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @has_moved = false
    @icon = is_white ? '♗' : '♝'
    super(position, is_white, @icon)
  end

  def valid_move?(end_pos, board)
    on_board?(end_pos) && move_valid?(end_pos) && path_clear?(end_pos, board) && destination_valid?(end_pos, board)
  end

  def move_to(new_pos)
    @position = new_pos
    mark_moved!
  end

  private

  def move_valid?(end_pos)
    diagonal_move?(end_pos)
  end

  def diagonal_move?(end_pos)
    (end_pos[0] - x).abs == (end_pos[1] - y).abs
  end

  def path_clear?(end_pos, board)
    step_row = (end_pos[0] - x).positive? ? 1 : -1
    step_col = (end_pos[1] - y).positive? ? 1 : -1

    current_row = x + step_row
    current_col = y + step_col

    while current_row != end_pos[0]
      return false unless board[current_row][current_col].nil?

      current_row += step_row
      current_col += step_col
    end

    true
  end

  def destination_valid?(end_pos, board)
    dest_piece = board[end_pos[0]][end_pos[1]]
    dest_piece.nil? || dest_piece.color != color
  end
end
