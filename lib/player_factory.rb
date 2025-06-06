class PlayerFactory
  def self.create_player(type, name, color, difficulty = :easy)
    case type
    when :human
      HumanPlayer.new(name, color)
    when :ai
      AIPlayer.new(name, color, difficulty)
    else
      raise ArgumentError, "Unknown player type: #{type}"
    end
  end

  def self.setup_game_players
    puts '=== Chess Game Setup ==='
    puts '1. Human vs Human'
    puts '2. Human vs AI'
    puts '3. AI vs AI'
    print 'Choose game mode (1-3): '

    mode = gets.chomp.to_i

    case mode
    when 1
      setup_human_vs_human
    when 2
      setup_human_vs_ai
    when 3
      setup_ai_vs_ai
    else
      puts 'Invalid choice. Setting up Human vs Human...'
      setup_human_vs_human
    end
  end

  private

  def self.setup_human_vs_human
    print 'Enter Player 1 (White) name: '
    player1_name = gets.chomp
    player1_name = 'Player 1' if player1_name.empty?

    print 'Enter Player 2 (Black) name: '
    player2_name = gets.chomp
    player2_name = 'Player 2' if player2_name.empty?

    [
      HumanPlayer.new(player1_name, 'white'),
      HumanPlayer.new(player2_name, 'black')
    ]
  end

  def self.setup_human_vs_ai
    print 'Enter your name: '
    human_name = gets.chomp
    human_name = 'Player' if human_name.empty?

    puts 'Choose AI difficulty:'
    puts '1. Easy'
    puts '2. Medium'
    puts '3. Hard'
    print 'Difficulty (1-3): '

    difficulty_choice = gets.chomp.to_i
    difficulty = case difficulty_choice
                 when 1 then :easy
                 when 2 then :medium
                 when 3 then :hard
                 else :easy
                 end

    puts 'Choose your color:'
    puts '1. White (you go first)'
    puts '2. Black (AI goes first)'
    print 'Color (1-2): '

    color_choice = gets.chomp.to_i

    if color_choice == 1
      [
        HumanPlayer.new(human_name, 'white'),
        AIPlayer.new("AI (#{difficulty.capitalize})", 'black', difficulty)
      ]
    else
      [
        AIPlayer.new("AI (#{difficulty.capitalize})", 'white', difficulty),
        HumanPlayer.new(human_name, 'black')
      ]
    end
  end

  def self.setup_ai_vs_ai
    puts 'AI vs AI Demo Mode'

    [
      AIPlayer.new('AI White (Medium)', 'white', :medium),
      AIPlayer.new('AI Black (Medium)', 'black', :medium)
    ]
  end
end
