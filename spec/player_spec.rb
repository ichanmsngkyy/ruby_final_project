# frozen_string_literal :true

# Player RSpec file
require_relative '../lib/player'
require_relative '../lib/AIplayer'

describe Player do
  describe '#initialize' do
    it 'creates a player with name, color, and default type' do
      player = Player.new('Alice', :white)
      expect(player.name).to eq('Alice')
      expect(player.color).to eq(:white)
      expect(player.type).to eq(:human)
    end

    it 'creates a player with specified type' do
      player = Player.new('Bob', :black, :ai)
      expect(player.name).to eq('Bob')
      expect(player.color).to eq(:black)
      expect(player.type).to eq(:ai)
    end
  end

  describe '#human?' do
    it 'returns true for human player' do
      player = Player.new('Alice', :white, :human)
      expect(player.human?).to be true
    end

    it 'returns false for AI player' do
      player = Player.new('Bob', :black, :ai)
      expect(player.human?).to be false
    end
  end

  describe '#ai?' do
    it 'returns true for AI player' do
      player = Player.new('Bob', :black, :ai)
      expect(player.ai?).to be true
    end

    it 'returns false for human player' do
      player = Player.new('Alice', :white, :human)
      expect(player.ai?).to be false
    end
  end

  describe '#get_move' do
    it 'raises NotImplementedError' do
      player = Player.new('Alice', :white)
      expect { player.get_move(double('board')) }.to raise_error(NotImplementedError)
    end
  end

  describe '#name=' do
    it 'allows changing player name' do
      player = Player.new('Alice', :white)
      player.name = 'Alicia'
      expect(player.name).to eq('Alicia')
    end
  end
end

describe HumanPlayer do
  describe '#initialize' do
    it 'creates a human player with correct attributes' do
      player = HumanPlayer.new('Alice', :white)
      expect(player.name).to eq('Alice')
      expect(player.color).to eq(:white)
      expect(player.type).to eq(:human)
      expect(player.human?).to be true
      expect(player.ai?).to be false
    end
  end

  describe '#get_move' do
    it 'returns nil' do
      player = HumanPlayer.new('Alice', :white)
      expect(player.get_move(double('board'))).to be_nil
    end
  end
end
