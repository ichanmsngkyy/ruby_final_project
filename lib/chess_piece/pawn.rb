# frozen_string_literal: true

# Pawn class movement
class Pawn < Piece
  attr_reader :has_moved, :double_stepped

  def initialize(position, is_white)
    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♙' : '♟'
    @position = position
    @has_moved = false
    @double_stepped = false
    super(position, is_white, @icon)
  end

  def move_to(new_pos)
    @position = new_pos
    mark_moved!
    @double_stepped = ((new_pos[0] - x).abs == 2)
  end

  def valid_move?(end_pos, board)
    pawn_move?(end_pos, board)
  end

  private

  def promotion_row?
    (color == 'white' && x == 0) || (color == 'black' && x == 7)
  end

  def direction
    color == 'white' ? -1 : 1
  end

  def pawn_move?(end_pos, board)
    on_board?(end_pos) && (forward_move?(end_pos, board) || diagonal_move?(end_pos, board))
  end

  def forward_move?(end_pos, board)
    dx = end_pos[0] - x
    dy = end_pos[1] - y
    dir = direction

    dest_piece = board[end_pos[0]][end_pos[1]]

    return false unless dy.zero?

    return true if dx == dir && dest_piece.nil?

    if dx == 2 * dir && !has_moved
      mid_x = x + dir
      return board[mid_x][y].nil? && dest_piece.nil?
    end

    false
  end

  def diagonal_move?(end_pos, board)
    dx = end_pos[0] - x
    dy = end_pos[1] - y
    dir = direction

    dest_piece = board[end_pos[0]][end_pos[1]]

    dx == dir && dy.abs == 1 && dest_piece && dest_piece.color != color
  end

  def set_double_stepped(value)
    @double_stepped = value
  end
end
