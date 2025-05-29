# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative '../lib/game'
require_relative '../lib/player'
require_relative '../lib/aiplayer'
require_relative '../lib/board'
require_relative '../lib/save_file'

# Save File Spec
describe SaveFile do
  let(:game) { Game.new('Alice', 'Bob') }
  let(:test_filename) { 'test_save' }
  let(:test_filepath) { File.join(SaveFile::SAVE_DIR, "#{test_filename}.json") }

  before do
    # Clean up any existing test files
    FileUtils.rm_rf(SaveFile::SAVE_DIR) if Dir.exist?(SaveFile::SAVE_DIR)
  end

  after do
    # Clean up test files
    FileUtils.rm_rf(SaveFile::SAVE_DIR) if Dir.exist?(SaveFile::SAVE_DIR)
  end

  describe '.save_game' do
    it 'creates save directory if it does not exist' do
      SaveFile.save_game(game, test_filename)
      expect(Dir.exist?(SaveFile::SAVE_DIR)).to be true
    end

    it 'saves game data to JSON file' do
      result = SaveFile.save_game(game, test_filename)
      expect(result).to be true
      expect(File.exist?(test_filepath)).to be true
    end

    it 'saves valid JSON data' do
      SaveFile.save_game(game, test_filename)
      data = JSON.parse(File.read(test_filepath), symbolize_names: true)
      expect(data).to have_key(:board_state)
      expect(data).to have_key(:players)
    end

    context 'when file write fails' do
      it 'returns false and prints error message' do
        allow(File).to receive(:write).and_raise(StandardError.new('Write failed'))
        expect { SaveFile.save_game(game, test_filename) }.to output(/Error saving game/).to_stdout
      end
    end
  end

  describe '.load_game' do
    context 'when save file exists' do
      before do
        SaveFile.save_game(game, test_filename)
      end

      it 'loads and returns game object' do
        loaded_game = SaveFile.load_game(test_filename)
        expect(loaded_game).to be_a(Game)
        expect(loaded_game.players.first.name).to eq('Alice')
      end
    end

    context 'when save file does not exist' do
      it 'returns nil and prints error message' do
        expect { SaveFile.load_game('nonexistent') }.to output(/Save file not found/).to_stdout
      end
    end

    context 'when JSON parsing fails' do
      before do
        Dir.mkdir(SaveFile::SAVE_DIR) unless Dir.exist?(SaveFile::SAVE_DIR)
        File.write(test_filepath, 'invalid json')
      end

      it 'returns nil and prints error message' do
        expect { SaveFile.load_game(test_filename) }.to output(/Error loading game/).to_stdout
      end
    end
  end

  describe '.list_saves' do
    context 'when save directory exists' do
      before do
        SaveFile.save_game(game, 'save1')
        SaveFile.save_game(game, 'save2')
      end

      it 'returns list of save filenames' do
        saves = SaveFile.list_saves
        expect(saves).to include('save1', 'save2')
      end
    end

    context 'when save directory does not exist' do
      it 'returns empty array' do
        saves = SaveFile.list_saves
        expect(saves).to eq([])
      end
    end
  end
end
