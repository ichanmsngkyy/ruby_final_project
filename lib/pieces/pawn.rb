# frozen_string_literal: true

require_relative 'piece'

# Pawn movement class
class Pawn < Piece
  attr_reader :position, :icon

  def initialize(position, is_white)
    @icon = is_white ? '♙' : '♟'
    super(position, is_white, @icon)
  end

  # Checking if move is valid
  def valid_move?(end_pos, board)
    return false unless on_board?(end_pos)

    if forward_move?(end_pos)
      valid_forward_move?(end_pos, board)
    elsif capture_move?(end_pos)
      valid_capture_move?(end_pos, board)
    else
      false
    end
  end

  private

  # Forward Movement
  def forward_move?(end_pos)
    dx = (end_pos[0] - position[0])
    dy = (end_pos[1] - position[1]).abs

    correct_direction?(dx) && dy.zero?
  end

  # Diagonal Movement
  def capture_move?(end_pos)
    dx = (end_pos[0] - position[0])
    dy = (end_pos[1] - position[1]).abs

    correct_direction_one?(dx) && dy == 1
  end

  # Pawn movement
  def valid_forward_move?(end_pos, board)
    dx = (end_pos[0] - position[0])

    if dx.abs == 1
      valid_single_step?(end_pos, board)
    elsif dx.abs == 2
      valid_double_step?(end_pos, board)
    else
      false
    end
  end

  # Check if capture is valid
  def valid_capture_move?(end_pos, board)
    target_piece = board[end_pos]

    return false if target_piece.nil?
    return false if target_piece.color == color

    true
  end

  # Check if step forward is valid
  def valid_single_step?(end_pos, board)
    target_piece = board[end_pos]
    target_piece.nil?
  end

  # Check if double step forward is valid
  def valid_double_step?(end_pos, board)
    return false if @has_moved

    return false unless clear_path?(end_pos, board)

    target_piece = board[end_pos]
    target_piece.nil?
  end

  # Forward movement checker
  def correct_direction_one?(dx)
    dx == (color == 'white' ? 1 : -1)
  end

  # Direction checker
  def correct_direction?(dx)
    if color == 'white'
      [1, 2].include?(dx)
    else
      [-1, -2].include?(dx)
    end
  end
end
