# frozen_string_literal: true

require_relative '../lib/board'
# Board Rspec file
#
describe Board do
  subject(:board) { described_class.new }

  describe '#initialize' do
    it 'intialize an empty 8x8 array' do
      expect(board.grid.size).to eq(8)
    end
  end
end
