# frozen_string_literal: true

require_relative '../lib/board'
# Board Rspec file
#
describe Board do
  subject(:board) { described_class.new }

  describe '#initialize' do
    context 'when the board is created' do
      it 'intialize an empty 8x8 array' do
        expect(board.grid.size).to eq(8)
      end
    end

    context 'when setting up pieces' do
      it 'sets up pieces correctly' do
        expect(board[[0, 0]]).to be_a(Rook)
        expect(board[[0, 0]].color).to be('white')

        expect(board[[0, 4]]).to be_a(King)
        expect(board[[7, 4]]).to be_a(King)
        expect(board[[7, 4]].color).to eq('black')

        expect(board[[1, 0]]).to be_a(Pawn)
        expect(board[[6, 0]]).to be_a(Pawn)

        expect(board[[3, 3]]).to be_nil
      end
    end
  end

  describe '#[] and #[]=' do
    context 'when we set and get piece' do
      it 'sets and gets the piece in specific position' do
        piece = double('piece')
        board[[2, 3]] = piece
        expect(board[[2, 3]]).to eq(piece)
      end

      it 'returns nil for empty position' do
        expect(board[[3, 2]]).to be_nil
      end
    end
  end

  describe '#move_piece' do
    context 'when piece is nil' do
      it 'returns false ' do
        expect(board.move_piece([0, 0], [1, 1])).to be false
      end
    end

    context 'when piece exist but move is invalid' do
      let(:piece) { double('piece') }

      before do
        allow(board).to receive(:[]).with([0, 0]).and_return(piece)
        allow(piece).to receive(:valid_move?).with([1, 1], board).and_return(false)
      end

      it 'return false' do
        expect(board.move_piece([0, 0], [1, 1])).to be false
      end

      it 'calls valid_move? on the piece' do
        expect(piece).to receive(:valid_move?).with([1, 1], board)
        board.move_piece([0, 0], [1, 1])
      end
    end
  end
  context 'when move is valid' do
    let(:piece) { double('piece') }

    before do
      allow(board).to receive(:[]).with([0, 0]).and_return(piece)
      allow(board).to receive(:[]=)
      allow(piece).to receive(:valid_move?).with([1, 0], board).and_return(true)
      allow(piece).to receive(:position=)
      allow(piece).to receive(:mark_moved!)
    end

    it 'returns true' do
      expect(board.move_piece([0, 0], [1, 0])).to be true
    end

    it 'updates pieces position' do
      board.move_piece([0, 0], [1, 0])
      expect(piece).to have_received(:position=).with([1, 0])
    end

    it 'marks piece as moved' do
      board.move_piece([0, 0], [1, 0])
      expect(piece).to have_received(:mark_moved!)
    end

    it 'updates board state correctly' do
      expect(board).to receive(:[]=).with([0, 0], nil)
      expect(board).to receive(:[]=).with([1, 0], piece)
      board.move_piece([0, 0], [1, 0])
    end
  end

  describe '#can_castle?' do
    context 'when conditions are met for castling' do
      before do
        board[[0, 1]] = nil
        board[[0, 2]] = nil
        board[[0, 3]] = nil
      end

      it 'returns true for white queenside castle when path is clear' do
        expect(board.can_castle?('white', 'queenside')).to be true
      end
    end

    context 'when king has moved' do
      before do
        king = board[[0, 4]]
        allow(king).to receive(:has_moved).and_return(true)
      end

      it 'returns false' do
        expect(board.can_castle?('white', 'kingside')).to be false
      end
    end

    context 'when rook has moved' do
      before do
        rook = board[[0, 0]]
        allow(rook).to receive(:has_moved).and_return(true)
      end

      it 'returns false' do
        expect(board.can_castle?('white', 'kingside')).to be false
      end
    end

    context 'when path is blocked' do
      it 'return false for white queenside when bishop is in the way' do
        expect(board.can_castle?('white', 'queenside')).to be false
      end
    end

    context 'when king is not found' do
      before do
        board[[0, 4]] = nil
      end

      it 'returns false' do
        expect(board.can_castle?('white', 'queenside')).to be false
      end
    end

    context 'when rook is not found' do
      before do
        board[[0, 0]] = nil
      end

      it 'returns false' do
        expect(board.can_castle?('white', 'queenside')).to be false
      end
    end

    context 'when king is in check' do
      before do
        board[[0, 1]] = nil
        board[[0, 2]] = nil
        board[[0, 3]] = nil
        board[[1, 4]] = Rook.new([1, 4], false)
      end
      it 'return false' do
        expect(board.can_castle?('white', 'queenside')).to be false
      end
    end
  end
end
