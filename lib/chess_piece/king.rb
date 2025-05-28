# frozen_string_literal: true

# King class movement
class King < Piece
  attr_reader :has_moved

  QUEENSIDE_PATH = [1, 2, 3].freeze
  QUEENSIDE_KING_PATH = [4, 3, 2].freeze
  KINGSIDE_PATH = [5, 6].freeze
  KINGSIDE_KING_PATH = [4, 5, 6].freeze

  def initialize(position, is_white)
    @has_moved = false
    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♔' : '♚'
    super(position, is_white, @icon)
  end

  def can_castle?(rook, board) # rubocop:disable Metrics/PerceivedComplexity
    return false unless rook.is_a?(Rook) && !rook.has_moved && !@has_moved

    row = @color == 'white' ? 7 : 0
    side = rook.position[1] < @position[1] ? :queenside : :kingside

    path_cols = side == :queenside ? QUEENSIDE_PATH : KINGSIDE_PATH
    king_path_cols = side == :queenside ? QUEENSIDE_KING_PATH : KINGSIDE_KING_PATH

    return false unless path_clear?(board, row, path_cols)
    return false if in_check?(board)

    return false if king_path_cols.any? { |col| square_attacked?([row, col], board) }

    true
  end

  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)

    return true if king_move?(end_pos) && destination_valid?(end_pos, board)

    return false unless (end_pos[0] == x) && ((end_pos[1] - y).abs == 2)

    side = end_pos[1] < y ? :queenside : :kingside
    rook_col = side == :queenside ? 0 : 7
    rook = board[x][rook_col]

    can_castle?(rook, board)
  end

  def move_to(new_pos)
    @position = new_pos
    mark_moved!
  end

  private

  def king_move?(end_pos)
    (end_pos[0] - x).abs <= 1 && (end_pos[1] - y).abs <= 1
  end

  def destination_valid?(end_pos, board)
    return false unless on_board?(end_pos)

    dest_piece = board[end_pos[0]][end_pos[1]]
    dest_piece.nil? || dest_piece.color != color
  end

  def in_check?(board)
    king_pos = [x, y]

    board.each_with_index do |row, _i|
      row.each_with_index do |piece, _j|
        next if piece.nil? || piece.color == color || piece.is_a?(King)

        return true if piece.valid_move?(king_pos, board)
      end
    end
    false
  end

  def path_clear?(board, row, cols)
    cols.all? { |col| on_board?([row, col]) && board[row][col].nil? }
  end

  def square_attacked?(pos, board)
    board.each_with_index do |row, _i|
      row.each_with_index do |piece, _j|
        next if piece.nil? || piece.color == color

        return true if piece.valid_move?(pos, board)
      end
    end
    false
  end
end
