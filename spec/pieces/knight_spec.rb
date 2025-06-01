# frozen_string_literal: true

require_relative '../../lib/pieces/knight'
require_relative '../../lib/pieces/piece'

# Knight Rspec Class
describe Knight do
  let(:knight) { described_class.new([0, 0], true) }
  let(:board) { {} }

  describe '#initialize' do
    let(:white_knight) { described_class.new([0, 0], true) }
    let(:black_knight) { described_class.new([7, 0], false) }
    context 'when the rook is white ' do
      it 'has the correct icon, color and position' do
        expect(white_knight.icon).to eq('♘')
        expect(white_knight.color).to eq('white')
        expect(white_knight.position).to eq([0, 0])
      end
    end

    context 'when the rook is black' do
      it 'has the correct icon, color and position' do
        expect(black_knight.icon).to eq('♞')
        expect(black_knight.color).to eq('black')
        expect(black_knight.position).to eq([7, 0])
      end
    end
  end

  describe '#valid_move?' do
    context 'when the move is off the board' do
      it 'return false' do
        expect(knight.valid_move?([8, 0], board)).to be false
      end
    end

    context 'when the move is on the board' do
      it 'return true' do
        expect(knight.valid_move?([2, 1], board)).to be true
      end
    end

    context 'when the move is invalid knight movement' do
      it 'return false' do
        expect(knight.valid_move?([4, 3], board)).to be false
      end
    end

    context 'when the move is valid knight movement' do
      it 'return true' do
        expect(knight.valid_move?([2, 1], board)).to be true
      end
    end

    context 'when destination is not valid' do
      it 'return false' do
        friendly_piece = Piece.new([0, 0], true, '♘')
        board = { [1, 2] => friendly_piece }
        expect(knight.destination_valid?([1, 2], board)).to be false
      end
    end

    context 'when the destination is valid' do
      it 'return true' do
        board = {}
        expect(knight.destination_valid?([2, 1], board)).to be true
      end
    end
  end
end
