# frozen_string_literal: true

require_relative 'lib/game'

# Main class
class Main
  def self.run
    game = Game.new
    game.show_main_menu
  end
end

Main.run
