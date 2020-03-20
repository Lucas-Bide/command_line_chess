require_relative 'board'

class Main

  def initialize
    @board = nil
    @turn = true
    puts "Welcome to chess!"
    puts "To move from one square to another, enter the starting square followed by the ending square:"
    puts "Ex: Enter a move: e1 e2"
    play(load)
  end

  def load
    puts "Do you want to load the previous session or start a new session? L/N"
    answer = gets.chomp.downcase
    while answer != 'l' && answer != 'n'
      puts "enter 'l' or 'n'"
      answer = gets.chomp.downcase
    end

    if answer == 'l'
      puts "Loading the saved session"
      Dir.mkdir("sessions") unless Dir.exist?("sessions")
      if Dir.children("sessions") == []
        puts "Seems like there's no saved file. Let's start a new session"
        return false
      end
      session_data = Marshal::load(File.open("sessions/session", "r").read)
      marshal_load session_data
      true
    else
      puts "Starting a new session"
      false
    end
  end

  def marshal_dump
    [@board.marshal_dump, @turn]
  end

  def marshal_load array
    @board = Board.new
    @board.marshal_load(array[0])
    @turn = array[1]
  end

  def play load=false
    @board = Board.new unless load
    #board.set_up
    options = @board.piece_spots(@turn)
    while !options.empty?
      @board.display
      puts @turn ? "White" : "Black"
      puts "Enter a move (or 'draw' to quit or 'save' to save and end the session)"
      move = gets.chomp.downcase.strip
      while !options.include?(move[0..1]) || !@board.available_moves(move[0..1]).include?(move[3..4])
        break if move == 'draw'
        save if move == 'save'
        puts "Enter a valid move"
        move = gets.chomp.downcase.strip
      end
      break if move == 'draw'
      @board.move(move[0..1], move[3..4])
      system('clr') || system('clear')
      @turn = !@turn
      options = @board.piece_spots(@turn)
      puts "options: #{options}"
    end
    
    @board.display
    
    puts "Game over!"
    if @board.in_check?(@turn)
      puts "Checkmate... #{@turn ? 'Black' : 'White'} wins!"
    else
      puts "Stalemate!"
    end

    puts "Do you want to play again?"
    sleep(2)
    puts "Well, run the script again! hehe"
  end

  def save
    puts "Let's save the session"
    
    Dir.mkdir("sessions") unless Dir.exist?("sessions")

    File.open("sessions/session", "w") do |file|
      file.puts Marshal::dump(marshal_dump)
    end

    puts "Session saved. Come again!"
    exit
  end
end

Main.new
