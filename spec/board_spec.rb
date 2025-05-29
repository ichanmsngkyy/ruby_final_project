# frozen_string_literal: true

require_relative '../lib/board'


# Board Spec class
describe Board do
  let(:board) { Board.new }

  describe '#initialize' do
    it 'creates an 8x8 grid filled with nil' do
      expect(board.grid.size).to eq(8)
      expect(board.grid.first.size).to eq(8)
      expect(board.grid.flatten.all?(&:nil?)).to be true
    end

    it 'initializes last_move as nil' do
      expect(board.last_move).to be_nil
    end
  end

  describe '#setup_pieces' do
    before { board.setup_pieces }

    it 'places all pieces in correct starting positions' do
      # Check white pieces
      expect(board[[7, 0]]).to be_a(Rook)
      expect(board[[7, 0]].color).to eq('white')
      expect(board[[7, 4]]).to be_a(King)
      expect(board[[7, 4]].color).to eq('white')

      # Check black pieces
      expect(board[[0, 0]]).to be_a(Rook)
      expect(board[[0, 0]].color).to eq('black')
      expect(board[[0, 4]]).to be_a(King)
      expect(board[[0, 4]].color).to eq('black')

      # Check pawns
      (0..7).each do |col|
        expect(board[[1, col]]).to be_a(Pawn)
        expect(board[[1, col]].color).to eq('black')
        expect(board[[6, col]]).to be_a(Pawn)
        expect(board[[6, col]].color).to eq('white')
      end
    end
  end

  describe '#[]' do
    it 'returns the piece at given position' do
      board.setup_pieces
      piece = board[[0, 0]]
      expect(piece).to be_a(Rook)
      expect(piece.color).to eq('black')
    end

    it 'returns nil for empty squares' do
      expect(board[[3, 3]]).to be_nil
    end
  end

  describe '#[]=' do
    it 'sets a piece at given position' do
      piece = Rook.new([3, 3], true)
      board[[3, 3]] = piece
      expect(board[[3, 3]]).to eq(piece)
    end
  end

  describe '#move_piece' do
    before { board.setup_pieces }

    context 'with valid move' do
      it 'moves the piece and returns true' do
        result = board.move_piece([6, 4], [5, 4]) # White pawn forward
        expect(result).to be true
        expect(board[[5, 4]]).to be_a(Pawn)
        expect(board[[6, 4]]).to be_nil
      end

      it 'updates the last_move' do
        piece = board[[6, 4]]
        board.move_piece([6, 4], [5, 4])
        expect(board.last_move[:piece]).to eq(piece)
        expect(board.last_move[:start_pos]).to eq([6, 4])
        expect(board.last_move[:end_pos]).to eq([5, 4])
      end
    end

    context 'with invalid move' do
      it 'returns false and does not move piece' do
        result = board.move_piece([6, 4], [3, 4]) # Invalid pawn move
        expect(result).to be false
        expect(board[[6, 4]]).to be_a(Pawn)
        expect(board[[3, 4]]).to be_nil
      end
    end

    context 'with no piece at start position' do
      it 'returns false' do
        result = board.move_piece([3, 3], [4, 4])
        expect(result).to be false
      end
    end
  end

  describe '#display_board' do
    it 'outputs board representation without errors' do
      board.setup_pieces
      expect { board.display_board }.to output(/A   B   C   D   E   F   G   H/).to_stdout
    end
  end
end
