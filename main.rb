# frozen_string_literal: true

require_relative 'lib/game'

# Main class
class Main
  def self.run
    game = Game.new
    game.play
  end
end

Main.run
