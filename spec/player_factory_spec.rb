# frozen_string_literal: true

require_relative '.././lib/player'
require_relative '.././lib/AIplayer'
require_relative '.././lib/player_factory'
describe PlayerFactory do
  describe '.create_player' do
    it 'creates a human player' do
      player = PlayerFactory.create_player(:human, 'Alice', :white)
      expect(player).to be_instance_of(HumanPlayer)
      expect(player.name).to eq('Alice')
      expect(player.color).to eq(:white)
      expect(player.type).to eq(:human)
    end

    it 'creates an AI player with default difficulty' do
      player = PlayerFactory.create_player(:ai, 'AI', :black)
      expect(player).to be_instance_of(AIPlayer)
      expect(player.name).to eq('AI')
      expect(player.color).to eq(:black)
      expect(player.type).to eq(:ai)
    end

    it 'creates an AI player with specified difficulty' do
      player = PlayerFactory.create_player(:ai, 'AI', :black, :hard)
      expect(player).to be_instance_of(AIPlayer)
      expect(player.name).to eq('AI')
      expect(player.color).to eq(:black)
      expect(player.type).to eq(:ai)
    end

    it 'raises error for unknown player type' do
      expect do
        PlayerFactory.create_player(:unknown, 'Test', :white)
      end.to raise_error(ArgumentError, 'Unknown player type: unknown')
    end
  end

  describe '.setup_game_players' do
    it 'prompts for game mode selection' do
      allow(PlayerFactory).to receive(:gets).and_return("1\n")
      allow(PlayerFactory).to receive(:setup_human_vs_human).and_return([])
      expect { PlayerFactory.setup_game_players }.to output(/Chess Game Setup/).to_stdout
    end
  end

  describe 'private methods' do
    describe '.setup_human_vs_human' do
      it 'creates two human players' do
        allow(PlayerFactory).to receive(:gets).and_return("Alice\n", "Bob\n")

        players = PlayerFactory.send(:setup_human_vs_human)

        expect(players.length).to eq(2)
        expect(players[0]).to be_instance_of(HumanPlayer)
        expect(players[0].name).to eq('Alice')
        expect(players[0].color).to eq('white')
        expect(players[1]).to be_instance_of(HumanPlayer)
        expect(players[1].name).to eq('Bob')
        expect(players[1].color).to eq('black')
      end

      it 'uses default names for empty input' do
        allow(PlayerFactory).to receive(:gets).and_return("\n", "\n")

        players = PlayerFactory.send(:setup_human_vs_human)

        expect(players[0].name).to eq('Player 1')
        expect(players[1].name).to eq('Player 2')
      end
    end

    describe '.setup_human_vs_ai' do
      it 'creates human vs AI setup with human as white' do
        allow(PlayerFactory).to receive(:gets).and_return("Alice\n", "2\n", "1\n")

        players = PlayerFactory.send(:setup_human_vs_ai)

        expect(players[0]).to be_instance_of(HumanPlayer)
        expect(players[0].name).to eq('Alice')
        expect(players[0].color).to eq('white')
        expect(players[1]).to be_instance_of(AIPlayer)
        expect(players[1].color).to eq('black')
      end

      it 'creates human vs AI setup with human as black' do
        allow(PlayerFactory).to receive(:gets).and_return("Alice\n", "3\n", "2\n")

        players = PlayerFactory.send(:setup_human_vs_ai)

        expect(players[0]).to be_instance_of(AIPlayer)
        expect(players[0].color).to eq('white')
        expect(players[1]).to be_instance_of(HumanPlayer)
        expect(players[1].name).to eq('Alice')
        expect(players[1].color).to eq('black')
      end

      it 'uses default values for invalid input' do
        allow(PlayerFactory).to receive(:gets).and_return("\n", "99\n", "99\n")

        players = PlayerFactory.send(:setup_human_vs_ai)

        expect(players[0]).to be_instance_of(AIPlayer)
        expect(players[1]).to be_instance_of(HumanPlayer)
        expect(players[1].name).to eq('Player')
      end
    end

    describe '.setup_ai_vs_ai' do
      it 'creates two AI players' do
        players = PlayerFactory.send(:setup_ai_vs_ai)

        expect(players.length).to eq(2)
        expect(players[0]).to be_instance_of(AIPlayer)
        expect(players[0].name).to eq('AI White (Medium)')
        expect(players[0].color).to eq('white')
        expect(players[1]).to be_instance_of(AIPlayer)
        expect(players[1].name).to eq('AI Black (Medium)')
        expect(players[1].color).to eq('black')
      end
    end
  end
end
