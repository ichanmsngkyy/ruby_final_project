# frozen_string_literal: true

# Player Class
class Player
  attr_accessor :name
  attr_reader :color, :type

  def initialize(name, color, type = :human)
    @name = name
    @color = color
    @type = type
  end

  def human?
    @type == :human
  end

  def ai?
    @type == :ai
  end

  def get_move(board)
    raise NotImplementedError, 'Subclasses must implement get_move'
  end
end

class HumanPlayer < Player
  def initialize(name, color)
    super(name, color, :human)
  end

  def get_move(board)
    nil
  end
end
