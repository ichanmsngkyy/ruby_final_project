# frozen_string_literal: true

require 'rspec'
require_relative '../lib/player'
require_relative '../lib/AIplayer'

describe AIPlayer do
  let(:board) { double('board') }
  let(:white_pawn) { double('piece', color: 'white', class: double(name: 'Pawn')) }
  let(:black_queen) { double('piece', color: 'black', class: double(name: 'Queen')) }

  describe '#initialize' do
    it 'creates an AI player with default easy difficulty' do
      player = AIPlayer.new('AI', :black)
      expect(player.name).to eq('AI')
      expect(player.color).to eq(:black)
      expect(player.type).to eq(:ai)
      expect(player.ai?).to be true
      expect(player.human?).to be false
    end

    it 'creates an AI player with specified difficulty' do
      player = AIPlayer.new('AI', :black, :hard)
      expect(player.name).to eq('AI')
      expect(player.color).to eq(:black)
      expect(player.type).to eq(:ai)
    end
  end

  describe '#get_move' do
    let(:player) { AIPlayer.new('AI', 'white') }

    before do
      allow(player).to receive(:get_all_possible_moves).and_return([
                                                                     { start: [0, 0], end: [0, 1], piece: white_pawn }
                                                                   ])
    end

    context 'with easy difficulty' do
      let(:player) { AIPlayer.new('AI', 'white', :easy) }

      it 'returns a random move' do
        expect(player).to receive(:get_random_move).with(board)
        player.get_move(board)
      end
    end

    context 'with medium difficulty' do
      let(:player) { AIPlayer.new('AI', 'white', :medium) }

      it 'returns a basic strategic move' do
        expect(player).to receive(:get_basic_strategic_move).with(board)
        player.get_move(board)
      end
    end

    context 'with hard difficulty' do
      let(:player) { AIPlayer.new('AI', 'white', :hard) }

      it 'returns an advanced move' do
        expect(player).to receive(:get_advanced_move).with(board)
        player.get_move(board)
      end
    end

    context 'with unknown difficulty' do
      let(:player) { AIPlayer.new('AI', 'white', :unknown) }

      it 'defaults to random move' do
        expect(player).to receive(:get_random_move).with(board)
        player.get_move(board)
      end
    end
  end

  describe 'private methods' do
    let(:player) { AIPlayer.new('AI', 'white') }

    describe '#get_random_move' do
      it 'returns nil when no moves available' do
        allow(player).to receive(:get_all_possible_moves).and_return([])
        result = player.send(:get_random_move, board)
        expect(result).to be_nil
      end

      it 'returns a random move from available moves' do
        moves = [
          { start: [0, 0], end: [0, 1], piece: white_pawn },
          { start: [1, 0], end: [1, 1], piece: white_pawn }
        ]
        allow(player).to receive(:get_all_possible_moves).and_return(moves)
        result = player.send(:get_random_move, board)
        expect(moves).to include(result)
      end
    end

    describe '#get_basic_strategic_move' do
      it 'returns nil when no moves available' do
        allow(player).to receive(:get_all_possible_moves).and_return([])
        result = player.send(:get_basic_strategic_move, board)
        expect(result).to be_nil
      end

      it 'prioritizes capture moves' do
        capture_move = { start: [0, 0], end: [0, 1], piece: white_pawn }
        normal_move = { start: [1, 0], end: [1, 1], piece: white_pawn }

        allow(player).to receive(:get_all_possible_moves).and_return([normal_move, capture_move])
        allow(board).to receive(:[]).with([0, 1]).and_return(black_queen)
        allow(board).to receive(:[]).with([1, 1]).and_return(nil)

        result = player.send(:get_basic_strategic_move, board)
        expect(result).to eq(capture_move)
      end
    end

    describe '#get_advanced_move' do
      it 'returns nil when no moves available' do
        allow(player).to receive(:get_all_possible_moves).and_return([])
        result = player.send(:get_advanced_move, board)
        expect(result).to be_nil
      end

      it 'evaluates moves and returns the best one' do
        move1 = { start: [0, 0], end: [0, 1], piece: white_pawn }
        move2 = { start: [1, 0], end: [1, 1], piece: white_pawn }

        allow(player).to receive(:get_all_possible_moves).and_return([move1, move2])
        allow(player).to receive(:evaluate_move).with(move1, board).and_return(5)
        allow(player).to receive(:evaluate_move).with(move2, board).and_return(3)

        result = player.send(:get_advanced_move, board)
        expect(result).to eq(move1)
      end
    end

    describe '#get_all_possible_moves' do
      it 'returns empty array when no pieces available' do
        allow(board).to receive(:[]).and_return(nil)
        result = player.send(:get_all_possible_moves, board)
        expect(result).to eq([])
      end

      it 'returns valid moves for player pieces' do
        piece = double('piece', color: 'white')
        allow(board).to receive(:[]).and_return(nil)
        allow(board).to receive(:[]).with([0, 0]).and_return(piece)
        allow(piece).to receive(:valid_move?).and_return(true)
        allow(player).to receive(:legal_move_check).and_return(true)

        result = player.send(:get_all_possible_moves, board)
        expect(result).not_to be_empty
      end
    end

    describe '#legal_move_check' do
      it 'checks if move leaves king safe' do
        piece = double('piece')
        allow(board).to receive(:[]).and_return(piece, nil)
        allow(board).to receive(:[]=)
        allow(piece).to receive(:respond_to?).with(:position=).and_return(true)
        allow(piece).to receive(:position=)
        allow(board).to receive(:in_check?).with('white').and_return(false)

        result = player.send(:legal_move_check, [0, 0], [0, 1], board)
        expect(result).to be true
      end
    end

    describe '#evaluate_move' do
      it 'gives higher score for capturing valuable pieces' do
        move = { start: [0, 0], end: [0, 1], piece: white_pawn }
        allow(board).to receive(:[]).with([0, 1]).and_return(black_queen)

        score = player.send(:evaluate_move, move, board)
        expect(score).to be > 0
      end

      it 'gives bonus for center control' do
        move = { start: [0, 0], end: [3, 3], piece: white_pawn }
        allow(board).to receive(:[]).with([3, 3]).and_return(nil)

        score = player.send(:evaluate_move, move, board)
        expect(score).to eq(0.8)
      end
    end
  end
end
