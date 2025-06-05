# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board'

# Game RSpec file
describe Game do
  let(:player1) { double('player1') }
  let(:player2) { double('player2') }
  subject(:game) { described_class.new(player1, player2) }

  describe '#intialize' do
    context 'when game start' do
      it 'creates board' do
        expect(game.board).to be_a(Board)
      end

      it 'assign players' do
        expect(game.players).to eq([player1, player2])
      end

      it 'assign current_player' do
        expect(game.current_player).to eq(player1)
      end

      it 'sets game status to in progress' do
        expect(game.game_status).to eq(:in_progress)
      end
    end

    context 'when creating multiple games' do
      it 'creates independent game instantce' do
        game2 = described_class.new(player1, player2)
        expect(game.board).not_to be(game2.board)
      end
    end

    context 'when verifying player order' do
      it 'assigns player 1 as white' do
        expect(game.players[0]).to be(player1)
      end

      it 'assign player 2 as black' do
        expect(game.players[1]).to be(player2)
      end
    end

    context 'when verifying board setup' do
      it 'creates board with initial setup' do
        expect(game.board.grid).not_to be_empty
      end
    end
  end

  describe '#play' do
    context 'when game starts' do
      let(:player1) { double('player1', name: 'Default1', color: 'white') }
      let(:player2) { double('player2', name: 'Default2', color: 'black') }

      before do
        allow(game).to receive(:gets).and_return(double(chomp: 'John'), double(chomp: 'Jane'))
        allow(game).to receive(:puts)
        allow(game).to receive(:print)
        allow(game).to receive(:game_over?).and_return(true)
        allow(game).to receive(:display_final_result)

        allow(player1).to receive(:name=)
        allow(player2).to receive(:name=)
        allow(player1).to receive(:name).and_return('John')
        allow(player2).to receive(:name).and_return('Jane')
      end
      it 'display welcome messages' do
        expect(game).to receive(:puts).with('Welcome to Chess!')
        game.play
      end

      it 'prompts for player 1 name' do
        expect(game).to receive(:print).with('Enter Player 1 (White) name: ')
        game.play
      end

      it 'prompts for player 2 name' do
        expect(game).to receive(:print).with('Enter Player 2 (Black) name: ')
        game.play
      end

      it 'sets player name correctly' do
        expect(player1).to receive(:name=).with('John')
        expect(player2).to receive(:name=).with('Jane')
        game.play
      end

      it 'displays matchup with player names' do
        expect(game).to receive(:puts).with('John (White) vs Jane (Black)')
        game.play
      end
    end
  end
end
