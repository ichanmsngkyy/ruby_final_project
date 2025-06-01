# frozen_string_literal: true

require_relative '../../lib/pieces/bishop'
require_relative '../../lib/pieces/piece'

# Bishop Rspec Class
describe Bishop do
  let(:bishop) { described_class.new([0, 0], true) }
  let(:board) { {} }

  describe '#initialize' do
    let(:white_bishop) { described_class.new([0, 0], true) }
    let(:black_bishop) { described_class.new([7, 0], false) }
    context 'when the bishop is white ' do
      it 'has the correct icon, color and position' do
        expect(white_bishop.icon).to eq('♗')
        expect(white_bishop.color).to eq('white')
        expect(white_bishop.position).to eq([0, 0])
      end
    end

    context 'when the bishop is black' do
      it 'has the correct icon, color and position' do
        expect(black_bishop.icon).to eq('♝')
        expect(black_bishop.color).to eq('black')
        expect(black_bishop.position).to eq([7, 0])
      end
    end
  end

  describe '#valid_move?' do
    context 'when the move is off the board' do
      it 'returns false' do
        expect(bishop.valid_move?([8, 0], board)).to be false
      end
    end

    context 'when the move is on the board' do
      it 'returns true' do
        expect(bishop.valid_move?([2, 2], board)).to be true
      end
    end

    context 'when the move is invalid bishop movement' do
      it 'returns false' do
        expect(bishop.valid_move?([4, 3], board)).to be false
      end
    end

    context 'when the move is valid bishop movement' do
      it 'returns true' do
        expect(bishop.valid_move?([2, 2], board)).to be true
      end
    end

    context 'when path is not clear' do
      it 'returns false' do
        board = Hash.new(nil)
        board[[2, 2]] = double('Piece')
        expect(bishop.valid_move?([3, 3], board)).to be false
      end
    end

    context 'when  path is clear' do
      it 'returns true' do
        expect(bishop.valid_move?([2, 2], board)).to be true
      end
    end

    context 'when destination is not valid' do
      it 'returns false' do
        friendly_piece = Piece.new([0, 0], true, '♗')
        board = { [2, 2] => friendly_piece }
        expect(bishop.valid_move?([2, 2], board)).to be false
      end
    end

    context 'when the destination is valid' do
      it 'returns true' do
        expect(bishop.valid_move?([2, 2], board)).to be true
      end
    end
  end
end
