# frozen_string_literal: true

require_relative '../lib/board'
# Board Rspec file

describe Board do
  subject(:board) { described_class.new }

  describe '#initialize' do
    context 'when the board is created' do
      it 'initializes an empty 8x8 array' do
        expect(board.grid.size).to eq(8)
      end
    end

    context 'when setting up pieces' do
      it 'sets up pieces correctly' do
        expect(board[[0, 0]]).to be_a(Rook)
        expect(board[[0, 0]].color).to eq('white')

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
      it 'returns false' do
        board[[4, 4]] = nil # Make sure position is empty
        expect(board.move_piece([4, 4], [5, 5])).to be false
      end
    end

    context 'when piece exists but move is invalid' do
      let(:piece) { double('piece') }

      before do
        board[[0, 0]] = piece
        allow(piece).to receive(:valid_move?).with([1, 1], board).and_return(false)
      end

      it 'returns false' do
        expect(board.move_piece([0, 0], [1, 1])).to be false
      end

      it 'calls valid_move? on the piece' do
        expect(piece).to receive(:valid_move?).with([1, 1], board)
        board.move_piece([0, 0], [1, 1])
      end
    end

    context 'when move is valid' do
      let(:piece) { double('piece') }

      before do
        board[[2, 2]] = piece # Use empty position
        allow(piece).to receive(:valid_move?).with([3, 3], board).and_return(true)
        allow(piece).to receive(:position=)
        allow(piece).to receive(:mark_moved!)
        allow(piece).to receive(:is_a?).with(Pawn).and_return(false) # Not a pawn
      end

      it 'returns true' do
        expect(board.move_piece([2, 2], [3, 3])).to be true
      end

      it 'updates pieces position' do
        board.move_piece([2, 2], [3, 3])
        expect(piece).to have_received(:position=).with([3, 3])
      end

      it 'marks piece as moved' do
        board.move_piece([2, 2], [3, 3])
        expect(piece).to have_received(:mark_moved!)
      end

      it 'updates board state correctly' do
        board.move_piece([2, 2], [3, 3])
        expect(board[[2, 2]]).to be_nil
        expect(board[[3, 3]]).to eq(piece)
      end
    end

    context 'when moving a pawn that needs promotion' do
      let(:pawn) { double('pawn') }
      let(:queen) { double('queen') }

      before do
        board[[6, 0]] = pawn # Place pawn near promotion
        allow(pawn).to receive(:valid_move?).with([7, 0], board).and_return(true)
        allow(pawn).to receive(:position=)
        allow(pawn).to receive(:mark_moved!)
        allow(pawn).to receive(:is_a?).with(Pawn).and_return(true)
        allow(pawn).to receive(:color).and_return('white')
        allow(Queen).to receive(:new).with([7, 0], true).and_return(queen)
      end

      it 'promotes the pawn after moving' do
        board.move_piece([6, 0], [7, 0])
        expect(board[[7, 0]]).to eq(queen)
      end
    end
  end

  describe '#can_castle?' do
    context 'when conditions are met for castling' do
      before do
        # Clear path for queenside castling
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
        expect(board.can_castle?('white', 'queenside')).to be false
      end
    end

    context 'when path is blocked' do
      it 'returns false for white queenside when bishop is in the way' do
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
        # Clear path for queenside castling
        board[[0, 1]] = nil
        board[[0, 2]] = nil
        board[[0, 3]] = nil
        # Place attacking rook
        board[[1, 4]] = Rook.new([1, 4], false)
      end

      it 'returns false' do
        expect(board.can_castle?('white', 'queenside')).to be false
      end
    end
  end

  describe '#pawn_promotion_needed?' do
    context 'when white pawn reaches rank 7' do
      let(:white_pawn) { Pawn.new([7, 0], true) }

      before do
        board[[7, 0]] = white_pawn
      end

      it 'returns true' do
        expect(board.pawn_promotion_needed?([7, 0])).to be true
      end
    end

    context 'when black pawn reaches rank 0' do
      let(:black_pawn) { Pawn.new([0, 0], false) }

      before do
        board[[0, 0]] = black_pawn
      end

      it 'returns true' do
        expect(board.pawn_promotion_needed?([0, 0])).to be true
      end
    end

    context 'when pawn is not at promotion rank' do
      let(:white_pawn) { Pawn.new([5, 0], true) }

      before do
        board[[5, 0]] = white_pawn
      end

      it 'returns false' do
        expect(board.pawn_promotion_needed?([5, 0])).to be false
      end
    end

    context 'when piece is not a pawn' do
      let(:queen) { Queen.new([7, 0], true) }

      before do
        board[[7, 0]] = queen
      end

      it 'returns false' do
        expect(board.pawn_promotion_needed?([7, 0])).to be false
      end
    end
  end

  describe '#promote_pawn' do
    let(:white_pawn) { Pawn.new([7, 0], true) }

    before do
      board[[7, 0]] = white_pawn
    end

    it 'promotes pawn to queen by default' do
      board.promote_pawn([7, 0])
      expect(board[[7, 0]]).to be_a(Queen)
      expect(board[[7, 0]].color).to eq('white')  # Expect string, not boolean
    end

    it 'promotes pawn to specified piece' do
      board.promote_pawn([7, 0], 'rook')
      expect(board[[7, 0]]).to be_a(Rook)
      expect(board[[7, 0]].color).to eq('white')  # Use color consistently
    end
  end
end
