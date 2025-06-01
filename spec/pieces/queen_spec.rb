# frozen_string_literal: true

require_relative '../../lib/pieces/queen'
require_relative '../../lib/pieces/piece'

# Queen Rspec Class
describe Queen do
  let(:queen) { described_class.new([0, 0], true) }
  let(:board) { {} }

  describe '#initialize' do
    let(:white_queen) { described_class.new([0, 0], true) }
    let(:black_queen) { described_class.new([7, 0], false) }

    context 'when the queen is white' do
      it 'has the correct icon, color and position' do
        expect(white_queen.icon).to eq('♕')
        expect(white_queen.color).to eq('white')
        expect(white_queen.position).to eq([0, 0])
      end
    end

    context 'when the queen is black' do
      it 'has the correct icon, color and position' do
        expect(black_queen.icon).to eq('♛')
        expect(black_queen.color).to eq('black')
        expect(black_queen.position).to eq([7, 0])
      end
    end
  end

  describe '#valid_move?' do
    context 'when the move is off the board' do
      it 'returns false' do
        expect(queen.valid_move?([8, 0], board)).to be false
      end
    end

    context 'when the move is invalid queen movement' do
      it 'returns false for knight-like moves' do
        expect(queen.valid_move?([2, 1], board)).to be false
      end

      it 'returns false for irregular moves' do
        expect(queen.valid_move?([4, 3], board)).to be false
      end
    end

    context 'when the move is valid queen movement' do
      it 'returns true for horizontal movement' do
        expect(queen.valid_move?([5, 0], board)).to be true
      end

      it 'returns true for vertical movement' do
        expect(queen.valid_move?([0, 3], board)).to be true
      end

      it 'returns true for diagonal movement' do
        expect(queen.valid_move?([5, 5], board)).to be true
      end
    end

    context 'when path is blocked' do
      it 'returns false when piece blocks horizontal path' do
        board_with_piece = { [2, 0] => double('Piece') }
        expect(queen.valid_move?([5, 0], board_with_piece)).to be false
      end

      it 'returns false when piece blocks vertical path' do
        board_with_piece = { [0, 2] => double('Piece') }
        expect(queen.valid_move?([0, 3], board_with_piece)).to be false
      end

      it 'returns false when piece blocks diagonal path' do
        board_with_piece = { [2, 2] => double('Piece') }
        expect(queen.valid_move?([4, 4], board_with_piece)).to be false
      end
    end

    context 'when destination has friendly piece' do
      it 'returns false' do
        friendly_piece = double('Piece', color: 'white')
        board_with_friendly = { [2, 2] => friendly_piece }
        expect(queen.valid_move?([2, 2], board_with_friendly)).to be false
      end
    end

    context 'when destination has enemy piece' do
      it 'returns true (allows capture)' do
        enemy_piece = double('Piece', color: 'black')
        board_with_enemy = { [2, 2] => enemy_piece }
        expect(queen.valid_move?([2, 2], board_with_enemy)).to be true
      end
    end

    context 'when destination is empty' do
      it 'returns true' do
        expect(queen.valid_move?([2, 2], board)).to be true
      end
    end
  end
end
