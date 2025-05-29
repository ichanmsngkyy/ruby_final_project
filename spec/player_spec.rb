# frozen_string_literal: true

require_relative '../lib/player'
require_relative '../lib/aiplayer'
require_relative '../lib/game'
require_relative '../lib/board'

# Player Spec
describe Player do
  let(:player) { Player.new('Alice', 'white') }

  describe '#initialize' do
    it 'sets name, color, and type' do
      expect(player.name).to eq('Alice')
      expect(player.color).to eq('white')
      expect(player.type).to eq('human')
    end
  end

  describe '#get_move' do
    let(:board) { Board.new }

    context 'with valid move input' do
      before do
        allow(player).to receive(:gets).and_return("e2 e4\n")
      end

      it 'returns parsed move coordinates' do
        move = player.get_move(board)
        expect(move).to eq([[6, 4], [4, 4]]) # e2 to e4 in array coordinates
      end
    end

    context 'with save command' do
      before do
        allow(player).to receive(:gets).and_return("save\n")
      end

      it 'returns :save symbol' do
        move = player.get_move(board)
        expect(move).to eq(:save)
      end
    end

    context 'with exit command' do
      before do
        allow(player).to receive(:gets).and_return("exit\n")
      end

      it 'returns :exit symbol' do
        move = player.get_move(board)
        expect(move).to eq(:exit)
      end
    end

    context 'with invalid input' do
      before do
        allow(player).to receive(:gets).and_return("invalid\n")
      end

      it 'returns nil' do
        move = player.get_move(board)
        expect(move).to be_nil
      end
    end
  end
end
