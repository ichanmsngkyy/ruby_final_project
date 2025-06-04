# frozen_string_literal:true

require_relative 'pieces/rook'
require_relative 'pieces/bishop'
require_relative 'pieces/knight'
require_relative 'pieces/king'
require_relative 'pieces/queen'
require_relative 'pieces/pawn'
require_relative 'pieces/piece'

# Board Class
class Board
  attr_reader :grid

  def initialize
    @grid = (Array.new(8) { Array.new(8) })
    setup_piece
  end

  def setup_piece
    white_pieces
    black_pieces
  end

  def white_pieces
    @grid[0][0] = Rook.new([0, 0], true)
    @grid[0][1] = Bishop.new([0, 1], true)
    @grid[0][2] = Knight.new([0, 2], true)
    @grid[0][3] = Queen.new([0, 3], true)
    @grid[0][4] = King.new([0, 4], true)
    @grid[0][5] = Knight.new([0, 5], true)
    @grid[0][6] = Bishop.new([0, 6], true)
    @grid[0][7] = Rook.new([0, 7], true)
    (0..7).each do |col|
      @grid[1][col] = Pawn.new([1, col], true)
    end
  end

  def black_pieces
    @grid[7][0] = Rook.new([7, 0], false)
    @grid[7][1] = Bishop.new([7, 1], false)
    @grid[7][2] = Knight.new([7, 2], false)
    @grid[7][3] = Queen.new([7, 3], false)
    @grid[7][4] = King.new([7, 4], false)
    @grid[7][5] = Knight.new([7, 5], false)
    @grid[7][6] = Bishop.new([7, 6], false)
    @grid[7][7] = Rook.new([7, 7], false)

    (0..7).each do |col|
      @grid[6][col] = Pawn.new([6, col], false)
    end
  end

  def [](position)
    row, col = position
    @grid[row][col]
  end

  def []=(position, piece)
    row, col = position
    @grid[row][col] = piece
  end

  def move_piece(start_pos, end_pos)
    piece = self[start_pos]

    return false if piece.nil?
    return false unless piece.valid_move?(end_pos, self)

    self[start_pos] = nil
    self[end_pos] = piece
    piece.position = end_pos
    piece.mark_moved!

    true
  end

  def can_castle?(color, side)
    king_position = find_king(color)
    rook_position = find_rook(color, side)

    return false if king_position.nil?
    return false if rook_position.nil?

    king = self[king_position]
    rook = self[rook_position]

    return false if king.has_moved || rook.has_moved

    squares_between = get_castle_path(color, side)
    squares_between.each do |square|
      return false unless self[square].nil?
    end

    return false if in_check?(color)

    opponent_color = color == 'white' ? 'black' : 'white'
    final_king_position = if side == 'kingside'
                            (color == 'white' ? [0, 6] : [7, 6])
                          else
                            (color == 'white' ? [0, 2] : [7, 2])
                          end
    path_squares = get_king_castle_path(color, side) # You need this helper
    path_squares.each do |square|
      return false if square_under_attack?(square, opponent_color)
    end
    return false if square_under_attack?(final_king_position, opponent_color)

    true
  end

  private

  def find_king(color)
    (0..7).each do |row|
      (0..7).each do |col|
        piece = @grid[row][col]
        return [row, col] if piece.is_a?(King) && piece.color == color
      end
    end
    nil
  end

  def find_rook(color, side)
    row = color == 'white' ? 0 : 7
    col = side == 'kingside' ? 7 : 0

    piece = @grid[row][col]
    return [row, col] if piece.is_a?(Rook) && piece.color == color

    nil
  end

  def in_check?(color)
    king_position = find_king(color)
    return false if king_position.nil?

    opponent_color = color == 'white' ? 'black' : 'white'
    square_under_attack?(king_position, opponent_color)
  end

  def square_under_attack?(position, color)
    (0..7).each do |row|
      (0..7).each do |col|
        piece = @grid[row][col]

        next if piece.nil? || piece.color != color

        return true if piece.valid_move?(position, self)
      end
    end
    false
  end

  def get_castle_path(color, side)
    king_position = find_king(color)
    find_rook(color, side)
    return false if king_position.nil?

    color == 'white' ? 'black' : 'white'

    if side == 'kingside'
      if color == 'white'
        [[0, 5], [0, 6]]
      else
        [[7, 5], [7, 6]]
      end
    elsif side == 'queenside'
      if color == 'white'
        [[0, 3], [0, 2]]
      else
        [[7, 3], [7, 2]]
      end
    end
  end

  def get_king_castle_path(color, side)
    get_castle_path(color, side)
  end
end
