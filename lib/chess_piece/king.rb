# frozen_string_literal: true

# King class movement
class King < Piece
  def initialize(position, is_white)
    @icon = is_white ? '♔' : '♚'
    super(position, is_white, @icon)
  end

  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)

    # Regular king move (one square in any direction)
    return destination_valid?(end_pos, board) && !move_into_check?(end_pos, board) if king_move?(end_pos)

    # Castling move (king moves 2 squares horizontally)
    return can_castle?(end_pos, board) if castling_move?(end_pos)

    false
  end

  private

  def king_move?(end_pos)
    (end_pos[0] - x).abs <= 1 && (end_pos[1] - y).abs <= 1
  end

  def castling_move?(end_pos)
    # King moves exactly 2 squares horizontally, no vertical movement
    dx = end_pos[0] - x
    dy = end_pos[1] - y
    dx.zero? && dy.abs == 2
  end

  def can_castle?(end_pos, board)
    return false if has_moved || in_check?(board)

    # Determine castling side
    queenside = end_pos[1] < y
    rook_col = queenside ? 0 : 7
    rook = board[[x, rook_col]]

    return false unless rook.is_a?(Rook) && !rook.has_moved

    # Check path is clear
    start_col = queenside ? 1 : 5
    end_col = queenside ? 3 : 6

    (start_col..end_col).each do |col|
      return false unless board[[x, col]].nil?
    end

    # Check king doesn't move through check
    king_path_cols = queenside ? [2, 3] : [5, 6]
    king_path_cols.each do |col|
      return false if square_attacked?([x, col], board)
    end

    true
  end

  def in_check?(board)
    square_attacked?([x, y], board)
  end

  def move_into_check?(end_pos, board)
    square_attacked?(end_pos, board)
  end

  def square_attacked?(pos, board)
    board.grid.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        next if piece.nil? || piece.color == color

        # Special handling for pawns to avoid infinite recursion
        if piece.is_a?(Pawn)
          return true if pawn_attacks_square?(piece, pos)
        elsif piece.is_a?(King)
          # King attacks adjacent squares
          piece_pos = [row_idx, col_idx]
          dx = (pos[0] - piece_pos[0]).abs
          dy = (pos[1] - piece_pos[1]).abs
          return true if dx <= 1 && dy <= 1 && (dx + dy).positive?
        elsif piece.valid_move?(pos, board)
          # For other pieces, use their valid_move? method
          # but create a temporary board state to avoid recursion
          return true
        end
      end
    end
    false
  end

  def pawn_attacks_square?(pawn, pos)
    pawn_dir = pawn.color == 'white' ? -1 : 1
    dx = pos[0] - pawn.x
    dy = pos[1] - pawn.y

    dx == pawn_dir && dy.abs == 1
  end
end
