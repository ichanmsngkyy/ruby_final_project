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
        expect(pawn.valid_move?([1, 1], board)).to be false
      end
    end

    context 'when destination is a forward move' do
      it 'returns true' do
        expect(pawn.valid_move?([2, 0], board)).to be true
      end
    end

    context 'when pawn has been moved' do
      it 'prevents double move after pawn has moved' do
        pawn.instance_variable_set(:@has_moved, true)
        expect(pawn.valid_move?([2, 0], board)).to be false
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

    context 'when black piece move is valid forward move' do
      let(:black) { described_class.new([7, 0], false) }
      it 'valid move for one square' do
        expect(black.valid_move?([6, 0], board)).to be true
      end

      it 'valid move for double square' do
        expect(black.valid_move?([5, 0], board)).to be true
      end
    end

    context 'if theres an piece in front' do
      it 'prevents pawn from moving if theres an friendly piece' do
        friendly_piece = double('Piece', color: 'white')
        board_with_friendly = { [1, 0] => friendly_piece }
        expect(pawn.valid_move?([1, 0], board_with_friendly)).to be false
      end

      it 'prevents pawn from moving if theres an enemy piece' do
        enemy_piece = double('Piece', color: 'black')
        board_with_enemy = { [1, 0] => enemy_piece }
        expect(pawn.valid_move?([1, 0], board_with_enemy)).to be false
      end
    end

    context 'it prevents backward movement' do
      it 'prevent pawn from moving backward' do
        expect(pawn.valid_move?([-1, 0], board)).to be false
      end

      it 'prevent pawn from moving sideways' do
        expect(pawn.valid_move?([0, 1], board)).to be false
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
      it 'returns true if there is an enemy piece' do
        enemy_piece = double('Piece', color: 'black')
        board_with_enemy_piece = { [1, 1] => enemy_piece }
        expect(pawn.valid_move?([1, 1], board_with_enemy_piece)).to be true
      end
    end

    context 'when the diagonal square is nil' do
      it 'return false' do
        expect(pawn.valid_move?([1, 1], board)).to be false
      end
    end
  end
end
