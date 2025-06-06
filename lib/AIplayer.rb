# frozen_string_literal: true

# AI class
class AIPlayer < Player
  PIECE_VALUES = {
    'Pawn' => 1,
    'Knight' => 3,
    'Bishop' => 3,
    'Rook' => 5,
    'Queen' => 9,
    'King' => 100
  }.freeze

  def initialize(name, color, difficulty = :easy)
    super(name, color, :ai)
    @difficulty = difficulty
  end

  def get_move(board)
    case @difficulty
    when :easy
      get_random_move(board)
    when :medium
      get_basic_strategic_move(board)
    when :hard
      get_advanced_move(board)
    else
      get_random_move(board)
    end
  end

  private

  def get_random_move(board)
    possible_moves = get_all_possible_moves(board)
    return nil if possible_moves.empty?

    possible_moves.sample
  end

  def get_basic_strategic_move(board)
    possible_moves = get_all_possible_moves(board)
    return nil if possible_moves.empty?

    capture_moves = possible_moves.select { |move| board[move[:end]].nil? == false }

    if capture_moves.any?
      best_capture = capture_moves.max_by do |move|
        target_piece = board[move[:end]]
        target_piece ? PIECE_VALUES[target_piece.class.name] : 0
      end
      return best_capture
    end

    possible_moves.sample
  end

  def get_advanced_move(board)
    possible_moves = get_all_possible_moves(board)
    return nil if possible_moves.empty?

    best_move = nil
    best_score = -Float::INFINITY

    possible_moves.each do |move|
      score = evaluate_move(move, board)
      if score > best_score
        best_score = score
        best_move = move
      end
    end

    best_move || possible_moves.sample
  end

  def get_all_possible_moves(board)
    moves = []

    (0..7).each do |row|
      (0..7).each do |col|
        piece = board[[row, col]]
        next if piece.nil? || piece.color != @color

        (0..7).each do |target_row|
          (0..7).each do |target_col|
            target_pos = [target_row, target_col]
            next if [row, col] == target_pos

            next unless piece.valid_move?(target_pos, board) &&
                        legal_move_check([row, col], target_pos, board)

            moves << {
              start: [row, col],
              end: target_pos,
              piece: piece
            }
          end
        end
      end
    end

    moves
  end

  def legal_move_check(start_pos, end_pos, board)
    original_piece = board[end_pos]
    piece = board[start_pos]

    board[end_pos] = piece
    board[start_pos] = nil
    piece.position = end_pos if piece.respond_to?(:position=)

    king_safe = !board.in_check?(@color)

    board[start_pos] = piece
    board[end_pos] = original_piece
    piece.position = start_pos if piece.respond_to?(:position=)

    king_safe
  end

  def evaluate_move(move, board)
    score = 0
    target_piece = board[move[:end]]

    score += PIECE_VALUES[target_piece.class.name] if target_piece

    center_squares = [[3, 3], [3, 4], [4, 3], [4, 4]]
    score += 0.5 if center_squares.include?(move[:end])

    if @color == 'white' && move[:start][0] == 0
      score += 0.3
    elsif @color == 'black' && move[:start][0] == 7
      score += 0.3
    end

    score
  end
end
