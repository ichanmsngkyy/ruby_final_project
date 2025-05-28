# frozen_string_literal: true

class AIPlayer < Player
  attr_reader :difficulty

  def initialize(name, color, difficulty = :easy)
    super(name, color)
    @type = 'ai'
    @difficulty = difficulty # :easy, :medium, :hard
  end

  def get_move(board)
    puts "#{@name} (AI - #{@difficulty}) is thinking..."
    sleep(1) # Simulate thinking time

    case @difficulty
    when :easy
      random_move(board)
    when :medium
      smart_move(board)
    when :hard
      best_move(board)
    else
      random_move(board)
    end
  end

  private

  def random_move(board)
    valid_moves = get_all_valid_moves(board)
    valid_moves.sample
  end

  def smart_move(board)
    valid_moves = get_all_valid_moves(board)

    # Prioritize captures
    capture_moves = valid_moves.select { |_start_pos, end_pos| board[end_pos] }
    return capture_moves.sample unless capture_moves.empty?

    # Otherwise, random move
    valid_moves.sample
  end

  def best_move(board)
    valid_moves = get_all_valid_moves(board)
    return valid_moves.sample if valid_moves.empty?

    # Simple evaluation: prioritize captures and center control
    best_move = nil
    best_score = -Float::INFINITY

    valid_moves.each do |start_pos, end_pos|
      score = evaluate_move(start_pos, end_pos, board)
      if score > best_score
        best_score = score
        best_move = [start_pos, end_pos]
      end
    end

    best_move
  end

  def evaluate_move(start_pos, end_pos, board)
    score = 0
    board[start_pos]
    target = board[end_pos]

    # Capture bonus
    score += piece_value(target) if target

    # Center control bonus
    center_squares = [[3, 3], [3, 4], [4, 3], [4, 4]]
    score += 10 if center_squares.include?(end_pos)

    # Piece development bonus (move pieces off back rank)
    back_rank = white? ? 7 : 0
    score += 5 if start_pos[0] == back_rank && end_pos[0] != back_rank

    score
  end

  def piece_value(piece)
    return 0 unless piece

    values = {
      'Pawn' => 10,
      'Knight' => 30,
      'Bishop' => 30,
      'Rook' => 50,
      'Queen' => 90,
      'King' => 1000
    }
    values[piece.class.name] || 0
  end

  def get_all_valid_moves(board)
    valid_moves = []

    board.grid.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        next unless piece && piece.color == @color

        start_pos = [row_idx, col_idx]

        # Check all possible end positions
        (0..7).each do |end_row|
          (0..7).each do |end_col|
            end_pos = [end_row, end_col]
            next if start_pos == end_pos

            valid_moves << [start_pos, end_pos] if piece.valid_move?(end_pos, board)
          end
        end
      end
    end

    valid_moves
  end
end
