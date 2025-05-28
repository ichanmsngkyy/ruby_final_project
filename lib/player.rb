# frozen_string_literal: true

require 'json'

class Player
  attr_reader :name, :color, :type

  def initialize(name, color)
    @name = name
    @color = color
    @type = 'human'
  end

  def get_move(_board)
    puts "#{@name}'s turn (#{@color})"
    puts "Enter your move (e.g., 'e2 e4') or 'save' to save game or 'exit' to quit:"

    input = gets.chomp.strip.downcase

    # Handle special commands
    case input
    when 'save'
      return :save
    when 'exit', 'quit'
      return :exit
    end

    # Parse move input
    parse_move(input)
  end

  private

  def parse_move(input)
    # Expected format: "e2 e4" or "e2e4"
    coords = input.gsub(/[^a-h1-8]/, '').scan(/[a-h][1-8]/)

    return nil unless coords.length == 2

    start_pos = algebraic_to_coords(coords[0])
    end_pos = algebraic_to_coords(coords[1])

    [start_pos, end_pos]
  end

  def algebraic_to_coords(algebraic)
    col = algebraic[0].ord - 'a'.ord
    row = 8 - algebraic[1].to_i
    [row, col]
  end
end

# AI Player class (simplified)
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
