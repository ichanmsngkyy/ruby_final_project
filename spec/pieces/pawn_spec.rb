# frozen_string_literal: true

require_relative '../../lib/pieces/pawn'

# Pawn RSpec class
describe Pawn do
  let(:pawn) { described_class.new([0, 0], true) }
  let(:board) { {} }

  describe '#initialize' do
    let(:white_pawn) { described_class.new([0, 0], true) }
    let(:black_pawn) { described_class.new([7, 0], false) }

    context 'when the pawn is white' do
      it 'has correct color, icon and position' do
        expect(white_pawn.icon).to eq('♙')
        expect(white_pawn.color).to eq('white')
        expect(white_pawn.position).to eq([0, 0])
      end
    end

    context 'when the pawn is black' do
      it 'has correct color, icon and position' do
        expect(black_pawn.icon).to eq('♟')
        expect(black_pawn.color).to eq('black')
        expect(black_pawn.position).to eq([7, 0])
      end
    end
  end

  describe '#valid_move?' do
    context 'when the move is off board' do
      it 'returns false' do
        expect(pawn.valid_move?([8, 0], board)).to be false
      end
    end

    context 'when the move is on board' do
      it 'returns true' do
        expect(pawn.valid_move?([2, 0], board)).to be true
      end
    end

    context 'when the move is not a forward move' do
      it 'returns false' do
        expect(pawn.valid_move?([3, 0], board)).to be false
      end
    end

    context 'when the move is a forward move' do
      it 'returns true' do
        expect(pawn.valid_move?([2, 0], board)).to be true
      end
    end

    context 'when the move is valid forward move' do
      it 'valid move for one square' do
        expect(pawn.valid_move?([1, 0], board)).to be true
      end

      it 'valid move for double square' do
        expect(pawn.valid_move?([2, 0], board)).to be true
      end
    end

    context 'when destination has no piece' do
      it 'returns false if the square is nil' do
        expect(pawn.valid_move?([1, 1], board)).to be false
      end
    end

    context 'when destination has friendly piece' do
      it 'returns false if there is an friendly piece' do
        friendly_piece = double('Piece', color: 'white')
        board_with_friendly = { [1, 1] => friendly_piece }
        expect(pawn.valid_move?([1, 1], board_with_friendly)).to be false
      end
    end

    context 'when destination has enemy piece' do
      it 'returns false if there is an friendly piece' do
        enemy_piece = double('Piece', color: 'black')
        board_with_enemy_piece = { [1, 1] => enemy_piece }
        expect(pawn.valid_move?([1, 1], board_with_enemy_piece)).to be true
      end
    end
  end
end
