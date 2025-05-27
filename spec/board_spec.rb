# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/chess_piece/piece'
require_relative '../lib/chess_piece/rook'
require_relative '../lib/chess_piece/bishop'
require_relative '../lib/chess_piece/pawn'
require_relative '../lib/chess_piece/knight'
require_relative '../lib/chess_piece/queen'
require_relative '../lib/chess_piece/king'

# Board Spec class
describe Board do
  subject(:board) { described_class.new }

  describe '#initialize' do
    it 'creates an empty grid' do
      expected_board = Array.new(8) { Array.new(8, nil) }
      board_before_setup = Board.new.instance_variable_get(:@grid)
      expect(board.instance_variable_get(:@grid)).to eq(board_before_setup)
    end
  end

  describe '#setup_pieces' do
    before { board.setup_pieces }

    it 'places pieces in correct starting positions' do
      expect(board.instance_variable_get(:@grid)[0][0]).to be_a(Rook)
      expect(board.instance_variable_get(:@grid)[0][0].color).to be('white')

      expect(board.instance_variable_get(:@grid)[7][0]).to be_a(Rook)
      expect(board.instance_variable_get(:@grid)[7][0].color).to be('black')
    end

    it 'sets up pawns correctly' do
      (0..7).each do |col|
        expect(board.instance_variable_get(:@grid)[1][col]).to be_a(Pawn)
        expect(board.instance_variable_get(:@grid)[6][col]).to be_a(Pawn)
      end
    end

    it 'ensures the correct number of placed pieces' do
      total_pieces = board.instance_variable_get(:@grid).flatten.compact.size
      expect(total_pieces).to eq(32)
    end
  end

  describe '#display_board' do
    let(:board) { described_class.new }

    it 'prints the board correctly' do
      expected_output = <<~BOARD
           A   B   C   D   E   F   G   H
        8 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        7 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        6 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        5 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        4 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        3 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        2 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        1 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
      BOARD

      expect { board.display_board }.to output(expected_output).to_stdout
    end

    it 'prints a board with pieces after setup' do
      board.setup_pieces

      expected_output = <<~BOARD
           A   B   C   D   E   F   G   H
        8 | ♜ | ♞ | ♝ | ♛ | ♚ | ♝ | ♞ | ♜ |#{' '}
        7 | ♟ | ♟ | ♟ | ♟ | ♟ | ♟ | ♟ | ♟ |#{' '}
        6 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        5 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        4 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        3 | _ | _ | _ | _ | _ | _ | _ | _ |#{' '}
        2 | ♙ | ♙ | ♙ | ♙ | ♙ | ♙ | ♙ | ♙ |#{' '}
        1 | ♖ | ♘ | ♗ | ♕ | ♔ | ♗ | ♘ | ♖ |#{' '}
      BOARD

      expect { board.display_board }.to output(expected_output).to_stdout
    end
  end
end
