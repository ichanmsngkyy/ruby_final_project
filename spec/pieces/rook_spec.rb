# frozen_string_literal: true

require_relative '../../lib/pieces/rook'
require_relative '../../lib/pieces/piece'

# Rook Rspec Class
describe Rook do
  let(:rook) { described_class.new([0, 0], true) }
  let(:board) { {} }

  describe '#initialize' do
    let(:white_rook) { described_class.new([0, 0], true) }
    let(:black_rook) { described_class.new([7, 0], false) }
    context 'when the rook is white ' do
      it 'has the correct icon, color and position' do
        expect(white_rook.icon).to eq('♖')
        expect(white_rook.color).to eq('white')
        expect(white_rook.position).to eq([0, 0])
      end
    end

    context 'when the rook is black' do
      it 'has the correct icon, color and position' do
        expect(black_rook.icon).to eq('♜')
        expect(black_rook.color).to eq('black')
        expect(black_rook.position).to eq([7, 0])
      end
    end
  end

  describe '#valid_move?' do
    context 'when the move is off the board' do
      it 'returns false' do
        expect(rook.valid_move?([8, 0], board)).to be false
      end
    end

    context 'when the move is on the board' do
      it 'returns true' do
        expect(rook.valid_move?([7, 0], board)).to be true
      end
    end

    context 'when the move is invalid rook movement' do
      it 'returns false' do
        expect(rook.valid_move?([4, 3], board)).to be false
      end
    end

    context 'when the move is valid rook movement' do
      it 'returns true' do
        expect(rook.valid_move?([1, 0], board)).to be true
      end
    end

    context 'when path is not clear' do
      it 'returns false' do
        board = Hash.new(nil)
        board[[1, 0]] = double('Piece')
        expect(rook.valid_move?([2, 0], board)).to be false
      end
    end

    context 'when  path is clear' do
      it 'returns true' do
        expect(rook.valid_move?([2, 0], board)).to be true
      end
    end

    context 'when destination is not valid' do
      it 'returns false' do
        friendly_piece = Piece.new([0, 0], true, '♖')
        board = { [0, 3] => friendly_piece }
        expect(rook.valid_move?([0, 3], board)).to be false
      end
    end

    context 'when the destination is valid' do
      it 'returns true' do
        board = {}
        expect(rook.valid_move?([2, 0], board)).to be true
      end
    end
  end
end
