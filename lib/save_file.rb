# frozen_string_literal: true

require 'json'

# SaveFile class
class SaveFile
  SAVE_DIR = 'saves'

  def self.save_game(game, filename)
    # Create saves directory if it doesn't exist
    Dir.mkdir(SAVE_DIR) unless Dir.exist?(SAVE_DIR)

    filepath = File.join(SAVE_DIR, "#{filename}.json")

    begin
      File.write(filepath, JSON.pretty_generate(game.to_hash))
      puts "Game saved successfully to #{filepath}"
      true
    rescue StandardError => e
      puts "Error saving game: #{e.message}"
      false
    end
  end

  def self.load_game(filename)
    filepath = File.join(SAVE_DIR, "#{filename}.json")

    unless File.exist?(filepath)
      puts "Save file not found: #{filepath}"
      return nil
    end

    begin
      data = JSON.parse(File.read(filepath), symbolize_names: true)
      game = Game.from_hash(data)
      puts "Game loaded successfully from #{filepath}"
      game
    rescue StandardError => e
      puts "Error loading game: #{e.message}"
      nil
    end
  end

  def self.list_saves
    return [] unless Dir.exist?(SAVE_DIR)

    Dir.glob(File.join(SAVE_DIR, '*.json')).map do |filepath|
      File.basename(filepath, '.json')
    end
  end
end
