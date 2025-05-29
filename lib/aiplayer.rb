# frozen_string_literal: true
require_relative 'player'

#Ai Class
class AIPlayer < Player
  attr_reader :difficulty

  def initialize(name, color, difficulty = :easy)
    super(name, color)
    @type = 'ai'
    @difficulty = difficulty
  end

  def get_move(board)
    puts "#{@name} (AI) is thinking..."
    sleep(1) # Simulate thinking time

    # Simple AI: find first valid move
    get_random_valid_move(board)
  end

  private

  def get_random_valid_move(board)
    valid_moves = []

    board.grid.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        next unless piece && piece.color == @color

        start_pos = [row_idx, col_idx]

        (0..7).each do |end_row|
          (0..7).each do |end_col|
            end_pos = [end_row, end_col]
            next if start_pos == end_pos

            valid_moves << [start_pos, end_pos] if piece.valid_move?(end_pos, board)
          end
        end
      end
    end

    valid_moves.sample
  end
end
