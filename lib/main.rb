require_relative 'board'

class Main

  def initialize
    puts "Welcome to chess!"
    puts "To move from one square to another, enter the starting square followed by the ending square:"
    puts "Ex: Enter a move: e1 e2"
    play
  end

  def play
    board = Board.new
    #board.set_up
    turn = true
    options = board.piece_spots(turn)
    while !options.empty?
      board.display
      puts turn ? "White" : "Black"
      puts "Enter a move (or 'draw' to quit)"
      move = gets.chomp.downcase.strip #'e7 e8'
      while !options.include?(move[0..1]) || !board.available_moves(move[0..1]).include?(move[3..4])
        break if move == 'draw'
        puts "Enter a valid move"
        move = gets.chomp.downcase.strip
      end
      break if move == 'draw'
      board.move(move[0..1], move[3..4])
      system('clr') || system('clear')
      turn = !turn
      options = board.piece_spots(turn)
      puts "options: #{options}"
    end
    board.display
    puts "Game over!"
    if board.in_check?(turn)
      puts "Checkmate... #{turn ? 'Black' : 'White'} wins!"
    else
      puts "Stalemate!"
    end
  end
end

Main.new
