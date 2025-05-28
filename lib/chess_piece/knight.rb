# frozen_string_literal: true

# Knight class movement
class Knight < Piece
  attr_reader :has_moved

  def initialize(position, is_white)
    @has_moved = false
    @color = is_white ? 'white' : 'black'
    @icon = is_white ? '♘' : '♞'
    super(position, is_white, @icon)
  end

  def valid_move?(end_pos, board)
    knight_move?(end_pos) && destination_valid?(end_pos, board)
  end

  def move_to(new_pos)
    @position = new_pos
    mark_moved!
  end

  private

  def knight_move?(end_pos)
    @moveset.any? do |dx, dy|
      x + dx == end_pos[0] && y + dy == end_pos[1]
    end
  end

  def destination_valid?(end_pos, board)
    dest_piece = board[end_pos[0]][end_pos[1]]
    dest_piece.nil? || dest_piece.color != color
  end
end
