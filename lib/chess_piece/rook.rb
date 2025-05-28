class Rook < Piece
  def initialize(position, is_white)
    @icon = is_white ? '♖' : '♜'
    super(position, is_white, @icon)
  end

  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)
    return false unless rook_move?(end_pos)
    return false unless clear_path?(end_pos, board)

    destination_valid?(end_pos, board)
  end

  private

  def rook_move?(end_pos)
    # Rook moves horizontally or vertically only
    dx = (end_pos[0] - x).abs
    dy = (end_pos[1] - y).abs
    (dx == 0 && dy > 0) || (dy == 0 && dx > 0)
  end
end
