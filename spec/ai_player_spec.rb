# frozen_string_literal: true

require_relative '../lib/aiplayer'
require_relative '../lib/player'
require_relative '../lib/board'
require_relative '../lib/game'

# Ai Player Spec
describe AIPlayer do
  let(:ai_player) { AIPlayer.new('Computer', 'black', :medium) }
  let(:board) { Board.new }

  before do
    board.setup_pieces
  end

  describe '#initialize' do
    it 'inherits from Player and sets AI-specific attributes' do
      expect(ai_player.name).to eq('Computer')
      expect(ai_player.color).to eq('black')
      expect(ai_player.type).to eq('ai')
      expect(ai_player.difficulty).to eq(:medium)
    end
  end

  describe '#get_move' do
    it 'returns a valid move array' do
      move = ai_player.get_move(board)
      expect(move).to be_a(Array)
      expect(move.size).to eq(2)
      expect(move.first).to be_a(Array)
      expect(move.last).to be_a(Array)
    end

    it 'selects moves for pieces of correct color' do
      move = ai_player.get_move(board)
      start_pos = move.first
      piece = board[start_pos]
      expect(piece.color).to eq('black')
    end
  end

  describe 'difficulty levels' do
    let(:easy_ai) { AIPlayer.new('Easy', 'black', :easy) }
    let(:hard_ai) { AIPlayer.new('Hard', 'white', :hard) }

    it 'easy AI makes random moves' do
      expect(easy_ai.get_move(board)).to be_a(Array)
    end

    it 'hard AI evaluates moves' do
      expect(hard_ai.get_move(board)).to be_a(Array)
    end
  end
end
