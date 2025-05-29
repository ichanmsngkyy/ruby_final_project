# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/player'
require_relative '../lib/aiplayer'
require_relative '../lib/board'
require_relative '../lib/save_file'
# Board Rspec
describe Board do
  let(:game) { Game.new('Alice', 'Bob') }

  describe '#initialize' do
    it 'creates a new board with pieces set up' do
      expect(game.board).to be_a(Board)
      expect(game.board[[0, 0]]).to be_a(Rook)
    end

    it 'creates two players' do
      expect(game.players.size).to eq(2)
      expect(game.players.first.name).to eq('Alice')
      expect(game.players.first.color).to eq('white')
      expect(game.players.last.name).to eq('Bob')
      expect(game.players.last.color).to eq('black')
    end

    it 'sets white player as current player' do
      expect(game.current_player).to eq(game.players.first)
    end

    it 'initializes game state as active' do
      expect(game.game_state).to eq(:active)
    end

    it 'initializes empty move history' do
      expect(game.move_history).to be_empty
    end
  end

  describe '#initialize with AI' do
    let(:ai_game) { Game.new('Human', 'Computer', :medium) }

    it 'creates human and AI players' do
      expect(ai_game.players.first).to be_a(Player)
      expect(ai_game.players.last).to be_a(AIPlayer)
      expect(ai_game.players.last.difficulty).to eq(:medium)
    end
  end

  describe '#to_hash' do
    it 'serializes game state to hash' do
      hash = game.to_hash
      expect(hash).to have_key(:board_state)
      expect(hash).to have_key(:current_player_index)
      expect(hash).to have_key(:players)
      expect(hash).to have_key(:game_state)
      expect(hash).to have_key(:move_history)
      expect(hash).to have_key(:move_count)
    end
  end

  describe '.from_hash' do
    it 'recreates game from hash' do
      original_hash = game.to_hash
      recreated_game = Game.from_hash(original_hash)

      expect(recreated_game).to be_a(Game)
      expect(recreated_game.players.first.name).to eq('Alice')
      expect(recreated_game.players.last.name).to eq('Bob')
      expect(recreated_game.game_state).to eq(:active)
    end
  end

  describe '#save_game' do
    it 'delegates to SaveFile.save_game' do
      expect(SaveFile).to receive(:save_game).with(game, 'test_save')
      game.save_game('test_save')
    end
  end

  describe '.load_game' do
    it 'delegates to SaveFile.load_game' do
      expect(SaveFile).to receive(:load_game).with('test_save')
      Game.load_game('test_save')
    end
  end
end
