# frozen_string_literal: true

# King class movement
class King < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @moveset = [
      [1, 0], [1, 1], [1, -1],
      [0, 1], [0, -1],
      [-1, 0], [-1, 1], [-1, -1]
    ]
    @has_moved = false
    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♔' : '♚'
    super(position, is_white, icon)
  end

  def can_castle?(rook, positions)
    return false unless rook.instance_of?(Rook) && !rook.has_moved && !@has_moved

    x = @color == 'white' ? 7 : 0 # Row for white (bottom) or black (top)
    y_dest = rook.y == 0 ? 2 : 6 # Queenside (2) or Kingside (6)

    # Ensure spaces between King & Rook are clear
    path = rook.x == 0 ? [1, 2, 3] : [5, 6]
    return false unless path.all? { |y| positions[x][y].nil? }

    # Ensure King is not in check (we only check current position, not future moves)
    return false if in_check?(positions)

    true
  end
end
