# frozen_string_literal: true

# Pawn class movement
class Pawn < Piece
  attr_reader :has_moved, :double_stepped

  def initialize(position, is_white)
    @icon = is_white ? '♙' : '♟'
    @double_stepped = false
    super(position, is_white, @icon)
  end

  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)

    pawn_move?(end_pos, board)
  end

  def move_to(new_pos)
    old_pos = @position.dup
    super(new_pos)

    # Check if this was a double step
    @double_stepped = (new_pos[0] - old_pos[0]).abs == 2
  end

  private

  def direction
    # White pawns move from row 6 to row 0, black pawns move from row 1 to row 7
    color == 'white' ? -1 : 1
  end

  def pawn_move?(end_pos, board)
    forward_move?(end_pos, board) || diagonal_capture?(end_pos, board)
  end

  def forward_move?(end_pos, board)
    dx = end_pos[0] - x
    dy = end_pos[1] - y
    dir = direction

    # Must move forward only (no sideways movement)
    return false unless dy.zero?

    dest_piece = board[end_pos]

    # Single step forward
    return true if dx == dir && dest_piece.nil?

    # Double step forward (only if haven't moved and path is clear)
    if dx == 2 * dir && !has_moved
      mid_pos = [x + dir, y]
      return board[mid_pos].nil? && dest_piece.nil?
    end

    false
  end

  def diagonal_capture?(end_pos, board)
    dx = end_pos[0] - x
    dy = end_pos[1] - y
    dir = direction

    # Must be diagonal move (one forward, one sideways)
    return false unless dx == dir && dy.abs == 1

    dest_piece = board[end_pos]

    # Regular capture
    return true if dest_piece && dest_piece.color != color

    # En passant capture (destination is empty but we're capturing)
    return en_passant_possible?(end_pos, board) if dest_piece.nil?

    false
  end

  def en_passant_possible?(end_pos, board)
    # Check if there's an enemy pawn beside us that just double-stepped
    enemy_pawn_pos = [x, end_pos[1]]
    enemy_pawn = board[enemy_pawn_pos]

    return false unless enemy_pawn.is_a?(Pawn)
    return false unless enemy_pawn.color != color
    return false unless enemy_pawn.double_stepped

    # Check if it was the last move
    last_move = board.last_move
    return false unless last_move
    return false unless last_move[:piece] == enemy_pawn

    # Verify it was indeed a double step
    (last_move[:start_pos][0] - last_move[:end_pos][0]).abs == 2
  end
end
