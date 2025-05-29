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
