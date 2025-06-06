# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/player'
require 'json'
require 'tempfile'

describe Game do
  # Mock PlayerFactory to avoid dependency issues
  before(:all) do
    # Create mock player classes if they don't exist
    unless defined?(HumanPlayer)
      class HumanPlayer
        attr_accessor :name, :color

        def initialize(name, color)
          @name = name
          @color = color
        end

        def human?
          true
        end

        def ai?
          false
        end

        def type
          'human'
        end
      end
    end

    unless defined?(AIPlayer)
      class AIPlayer
        attr_accessor :name, :color, :difficulty

        def initialize(name, color, difficulty = :easy)
          @name = name
          @color = color
          @difficulty = difficulty
        end

        def human?
          false
        end

        def ai?
          true
        end

        def type
          'ai'
        end

        def get_move(board)
          # Mock AI move - just return first valid move found
          (0..7).each do |row|
            (0..7).each do |col|
              piece = board[[row, col]]
              next if piece.nil? || piece.color != @color

              (0..7).each do |target_row|
                (0..7).each do |target_col|
                  target_pos = [target_row, target_col]
                  next if [row, col] == target_pos

                  if piece.respond_to?(:valid_move?) && piece.valid_move?(target_pos, board)
                    return { start: [row, col], end: target_pos }
                  end
                end
              end
            end
          end
          nil
        end
      end
    end

    unless defined?(PlayerFactory)
      class PlayerFactory
        def self.setup_game_players
          [
            HumanPlayer.new('Player1', 'white'),
            HumanPlayer.new('Player2', 'black')
          ]
        end
      end
    end
  end

  subject(:game) { described_class.new }

  describe '#initialize' do
    context 'when game starts' do
      it 'creates a board' do
        expect(game.board).to be_a(Board)
      end

      it 'sets up players using PlayerFactory' do
        expect(game.players).to be_an(Array)
        expect(game.players.length).to eq(2)
      end

      it 'assigns first player as current player' do
        expect(game.current_player).to eq(game.players[0])
      end

      it 'sets game status to in progress' do
        expect(game.game_status).to eq(:in_progress)
      end

      it 'initializes empty move history' do
        expect(game.instance_variable_get(:@move_history)).to eq([])
      end
    end

    context 'when creating multiple games' do
      it 'creates independent game instances' do
        game2 = described_class.new
        expect(game.board).not_to be(game2.board)
        expect(game.players).not_to be(game2.players)
      end
    end
  end

  describe '#make_move' do
    let(:mock_piece) { double('piece', color: 'white', position: [1, 4]) }

    context 'with valid algebraic notation' do
      before do
        allow(game.board).to receive(:[]).with([1, 4]).and_return(mock_piece)
        allow(game.board).to receive(:[]).with([3, 4]).and_return(nil)
        allow(game.board).to receive(:move_piece).and_return(true)
        allow(game.board).to receive(:in_check?).and_return(false)
      end

      it 'converts notation and makes move successfully' do
        result = game.make_move('e2', 'e4')
        expect(result).to be true
      end

      it 'calls move_piece on board with correct coordinates' do
        expect(game.board).to receive(:move_piece).with([1, 4], [3, 4])
        game.make_move('e2', 'e4')
      end
    end

    context 'with invalid coordinates' do
      it 'returns false for out of bounds start position' do
        result = game.make_move('z9', 'a1')
        expect(result).to be false
      end

      it 'returns false for out of bounds end position' do
        result = game.make_move('a1', 'z9')
        expect(result).to be false
      end
    end

    context 'when no piece at start position' do
      before do
        allow(game.board).to receive(:[]).and_return(nil)
      end

      it 'returns false' do
        result = game.make_move('e4', 'e5')
        expect(result).to be false
      end
    end

    context 'when trying to move opponent piece' do
      let(:opponent_piece) { double('piece', color: 'black') }

      before do
        allow(game.board).to receive(:[]).with([4, 4]).and_return(opponent_piece)
        allow(game.board).to receive(:[]).with([5, 4]).and_return(nil)
      end

      it 'returns false' do
        result = game.make_move('e5', 'e6')
        expect(result).to be false
      end
    end

    context 'when board move_piece fails' do
      before do
        allow(game.board).to receive(:[]).with([1, 4]).and_return(mock_piece)
        allow(game.board).to receive(:[]).with([3, 4]).and_return(nil)
        allow(game.board).to receive(:move_piece).and_return(false)
      end

      it 'returns false' do
        result = game.make_move('e2', 'e4')
        expect(result).to be false
      end
    end

    context 'when move would leave king in check' do
      before do
        allow(game.board).to receive(:[]).with([1, 4]).and_return(mock_piece)
        allow(game.board).to receive(:[]).with([3, 4]).and_return(nil)
        allow(game.board).to receive(:move_piece).and_return(true)
        allow(game.board).to receive(:in_check?).and_return(true)
        allow(game).to receive(:undo_last_move)
      end

      it 'returns false and undoes move' do
        expect(game).to receive(:undo_last_move).with([1, 4], [3, 4])
        result = game.make_move('e2', 'e4')
        expect(result).to be false
      end
    end
  end

  describe '#make_move_from_coords' do
    let(:mock_piece) { double('piece', color: 'white', position: [1, 4]) }

    context 'with valid coordinates' do
      before do
        allow(game.board).to receive(:[]).with([1, 4]).and_return(mock_piece)
        allow(game.board).to receive(:[]).with([3, 4]).and_return(nil)
        allow(game.board).to receive(:move_piece).and_return(true)
        allow(game.board).to receive(:in_check?).and_return(false)
      end

      it 'makes move successfully' do
        result = game.make_move_from_coords([1, 4], [3, 4])
        expect(result).to be true
      end
    end

    context 'with invalid coordinates' do
      it 'returns false for out of bounds coordinates' do
        result = game.make_move_from_coords([-1, 0], [0, 0])
        expect(result).to be false
      end
    end
  end

  describe '#convert_notation' do
    it 'converts algebraic notation to array coordinates' do
      expect(game.send(:convert_notation, 'a1')).to eq([0, 0])
      expect(game.send(:convert_notation, 'h8')).to eq([7, 7])
      expect(game.send(:convert_notation, 'e4')).to eq([3, 4])
      expect(game.send(:convert_notation, 'd5')).to eq([4, 3])
    end

    it 'returns array if already in array format' do
      expect(game.send(:convert_notation, [3, 4])).to eq([3, 4])
      expect(game.send(:convert_notation, [0, 0])).to eq([0, 0])
    end
  end

  describe '#valid_coordinates?' do
    it 'returns true for valid coordinates' do
      expect(game.send(:valid_coordinates?, [0, 0])).to be true
      expect(game.send(:valid_coordinates?, [7, 7])).to be true
      expect(game.send(:valid_coordinates?, [3, 4])).to be true
    end

    it 'returns false for invalid coordinates' do
      expect(game.send(:valid_coordinates?, [-1, 0])).to be false
      expect(game.send(:valid_coordinates?, [8, 0])).to be false
      expect(game.send(:valid_coordinates?, [0, -1])).to be false
      expect(game.send(:valid_coordinates?, [0, 8])).to be false
    end
  end

  describe '#coords_to_notation' do
    it 'converts coordinates to algebraic notation' do
      expect(game.send(:coords_to_notation, [0, 0])).to eq('a1')
      expect(game.send(:coords_to_notation, [7, 7])).to eq('h8')
      expect(game.send(:coords_to_notation, [3, 4])).to eq('e4')
      expect(game.send(:coords_to_notation, [4, 3])).to eq('d5')
    end
  end

  describe '#save_game' do
    let(:temp_file) { Tempfile.new('chess_save_test') }
    let(:filename) { temp_file.path }

    after do
      temp_file.close
      temp_file.unlink
    end

    before do
      allow(game).to receive(:serialize_board).and_return([])
      allow(game).to receive(:serialize_players).and_return([])
    end

    it 'saves game to specified filename' do
      result = game.save_game(filename)
      expect(result).to eq(filename)
      expect(File.exist?(filename)).to be true
    end

    it 'generates filename if none provided' do
      allow(Time).to receive_message_chain(:now, :strftime).and_return('20231215_120000')
      expected_filename = 'chess_save_20231215_120000.json'

      result = game.save_game
      expect(result).to eq(expected_filename)

      # Clean up generated file
      File.delete(expected_filename) if File.exist?(expected_filename)
    end

    it 'returns nil if file write fails' do
      allow(File).to receive(:write).and_raise(StandardError.new('Write error'))
      allow(game).to receive(:puts)

      result = game.save_game(filename)
      expect(result).to be nil
    end
  end

  describe '#load_game' do
    let(:temp_file) { Tempfile.new('chess_load_test') }
    let(:filename) { temp_file.path }

    let(:game_data) do
      {
        'board_state' => [],
        'current_player_index' => 0,
        'players' => [
          { 'name' => 'John', 'color' => 'white', 'type' => 'human' },
          { 'name' => 'Jane', 'color' => 'black', 'type' => 'human' }
        ],
        'game_status' => 'in_progress',
        'move_history' => []
      }
    end

    after do
      temp_file.close
      temp_file.unlink
    end

    context 'when file exists and is valid' do
      before do
        temp_file.write(JSON.generate(game_data))
        temp_file.rewind
        allow(game).to receive(:restore_board)
        allow(game).to receive(:puts)
      end

      it 'loads game successfully' do
        result = game.load_game(filename)
        expect(result).to be true
      end

      it 'restores current player' do
        game.load_game(filename)
        expect(game.current_player).to eq(game.players[0])
      end

      it 'restores game status' do
        game.load_game(filename)
        expect(game.game_status).to eq(:in_progress)
      end
    end

    context 'when file does not exist' do
      it 'returns false' do
        allow(game).to receive(:puts)
        result = game.load_game('nonexistent_file.json')
        expect(result).to be false
      end
    end

    context 'when file contains invalid JSON' do
      before do
        temp_file.write('invalid json content')
        temp_file.rewind
        allow(game).to receive(:puts)
      end

      it 'returns false' do
        result = game.load_game(filename)
        expect(result).to be false
      end
    end
  end

  describe '#list_save_files' do
    it 'returns empty array when no save files exist' do
      allow(Dir).to receive(:glob).with('chess_save_*.json').and_return([])
      allow(game).to receive(:puts)

      result = game.list_save_files
      expect(result).to eq([])
    end

    it 'returns sorted list of save files' do
      files = ['chess_save_20231214_110000', 'chess_save_20231215_120000.json.json']
      allow(Dir).to receive(:glob).with('chess_save_*.json').and_return(files)
      allow(game).to receive(:puts)

      files.each do |file|
        allow(File).to receive(:mtime).with(file).and_return(Time.now)
      end

      result = game.list_save_files
      expect(result).to eq(files.reverse) # Should be sorted in reverse order
    end
  end

  describe '#switch_player' do
    it 'switches from first player to second player' do
      initial_player = game.current_player
      game.send(:switch_player)
      expect(game.current_player).not_to eq(initial_player)
      expect(game.current_player).to eq(game.players[1])
    end

    it 'switches from second player back to first player' do
      game.send(:switch_player) # Switch to player 2
      game.send(:switch_player) # Switch back to player 1
      expect(game.current_player).to eq(game.players[0])
    end
  end

  describe '#checkmate?' do
    before do
      allow(game.board).to receive(:in_check?).with('white').and_return(true)
      allow(game).to receive(:no_legal_moves?).with('white').and_return(true)
    end

    it 'returns true when player is in check and has no legal moves' do
      expect(game.send(:checkmate?, 'white')).to be true
    end

    it 'returns false when player is not in check' do
      allow(game.board).to receive(:in_check?).with('white').and_return(false)
      expect(game.send(:checkmate?, 'white')).to be false
    end

    it 'returns false when player has legal moves' do
      allow(game).to receive(:no_legal_moves?).with('white').and_return(false)
      expect(game.send(:checkmate?, 'white')).to be false
    end
  end

  describe '#stalemate?' do
    before do
      allow(game.board).to receive(:in_check?).with('white').and_return(false)
      allow(game).to receive(:no_legal_moves?).with('white').and_return(true)
    end

    it 'returns true when player is not in check but has no legal moves' do
      expect(game.send(:stalemate?, 'white')).to be true
    end

    it 'returns false when player is in check' do
      allow(game.board).to receive(:in_check?).with('white').and_return(true)
      expect(game.send(:stalemate?, 'white')).to be false
    end

    it 'returns false when player has legal moves' do
      allow(game).to receive(:no_legal_moves?).with('white').and_return(false)
      expect(game.send(:stalemate?, 'white')).to be false
    end
  end

  describe '#game_over?' do
    it 'returns true when checkmate occurs' do
      allow(game).to receive(:checkmate?).and_return(true)
      allow(game).to receive(:stalemate?).and_return(false)
      expect(game.send(:game_over?)).to be true
    end

    it 'returns true when stalemate occurs' do
      allow(game).to receive(:checkmate?).and_return(false)
      allow(game).to receive(:stalemate?).and_return(true)
      expect(game.send(:game_over?)).to be true
    end

    it 'returns false when neither checkmate nor stalemate' do
      allow(game).to receive(:checkmate?).and_return(false)
      allow(game).to receive(:stalemate?).and_return(false)
      expect(game.send(:game_over?)).to be false
    end
  end

  describe '#record_move' do
    it 'adds move to move history' do
      expect do
        game.send(:record_move, 'e2', 'e4')
      end.to change { game.instance_variable_get(:@move_history).length }.by(1)
    end

    it 'records move details correctly' do
      game.send(:record_move, 'e2', 'e4')
      last_move = game.instance_variable_get(:@move_history).last

      expect(last_move[:from]).to eq('e2')
      expect(last_move[:to]).to eq('e4')
      expect(last_move[:player]).to eq(game.current_player.color)
      expect(last_move[:player_name]).to eq(game.current_player.name)
      expect(last_move[:timestamp]).to be_a(Time)
    end
  end

  describe 'private helper methods' do
    describe '#any_human_players?' do
      it 'returns true when there are human players' do
        expect(game.send(:any_human_players?)).to be true
      end

      it 'returns false when all players are AI' do
        ai_players = [
          AIPlayer.new('AI1', 'white'),
          AIPlayer.new('AI2', 'black')
        ]
        game.instance_variable_set(:@players, ai_players)

        expect(game.send(:any_human_players?)).to be false
      end
    end
  end
end
