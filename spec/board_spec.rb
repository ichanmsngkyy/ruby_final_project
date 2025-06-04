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

    describe '#move_piece'
  end
end
