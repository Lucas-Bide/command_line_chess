require_relative 'piece'

class String
  
  def black
    "\e[30m#{self}\e[0m"
  end
  
  def bg_red
    "\e[41m#{self}\e[0m"
  end

  def bg_brown
    "\e[43m#{self}\e[0m"
  end

  def bg_blue
    "\e[44m#{self}\e[0m"
  end
end

class Board
  # ♔ ♕ ♖ ♗ ♘ ♙ 
  # ♚ ♛ ♜ ♝ ♞ ♟

  def initialize
    @board = Array.new(8) { Array.new(8, '  ') }

    pieces = ['rook', 'knight', 'bishop', 'queen', 'king', 'bishop', 'knight', 'rook']
    [[true, 6, 7],[false, 1, 0]].each do |vals|
      @board[vals[1]].each_with_index do |v, i|
        @board[vals[1]][i] = Piece.new vals[0], "pawn", [vals[1], i]
      end

      @board[vals[2]].each_with_index do |v, i|
        @board[vals[2]][i] = Piece.new vals[0], pieces[i], [vals[1], i] #pos display is [+1, (+97).chr]
      end
      pieces.reverse!
    end

    @black_king_position = [0,3]
    @white_king_posision = [7,4]
  end

  def display
    counter = 0
    puts "  " + "                    ".bg_red
    @board.each_with_index do |row, i| 
      print "  " + "#{8-i} ".bg_red 
      row.each do |spot|
        square = spot.to_s
        if spot.is_a?(Piece) && !spot.color
          square = square.black
        end
        print counter % 2 == 0 ? square.bg_blue : square.bg_brown
        counter += 1
      end 
      puts "  ".bg_red
      counter += 1
    end
    puts "  " + "  a b c d e f g h   ".bg_red
         
  end
end

Board.new.display
