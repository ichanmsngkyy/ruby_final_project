# frozen_string_literal: true

require_relative '../lib/board'

# Board Spec class
describe Board do
  subject(:board) { described_class.new }

  describe '#initialize' do
    it 'creates an empty grid' do
      expected_board = Array.new(8) { Array.new(8, nil) }
      expect(board.instance_variable_get(:@grid)).to eq(expected_board)
    end
  end
end
