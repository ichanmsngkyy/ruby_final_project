# frozen_string_literal: true

# Queen class movements
class Queen < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @has_moved = false
    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♕' : '♛'
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
    queen_move?(end_pos)
  end

  def queen_move?(end_pos)
    dx = (end_pos[0] - x).abs
    dy = (end_pos[1] - y).abs
    dx == dy || dx.zero? || dy.zero?
  end

  def path_clear?(end_pos, board)
    dx = end_pos[0] - x
    dy = end_pos[1] - y

    step_x = dx.zero? ? 0 : dx / dx.abs
    step_y = dy.zero? ? 0 : dy / dy.abs

    curr_x = x + step_x
    curr_y = y + step_y

    while [curr_x, curr_y] != end_pos
      return false unless board[curr_x][curr_y].nil?

      curr_x += step_x
      curr_y += step_y
    end
    true
  end

  def destination_valid?(end_pos, board)
    dest_piece = board[end_pos[0]][end_pos[1]]
    dest_piece.nil? || dest_piece.color != color
  end
end
