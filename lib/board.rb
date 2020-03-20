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
        @board[vals[1]][i] = Piece.new vals[0], "pawn"
      end

      @board[vals[2]].each_with_index do |v, i|
        @board[vals[2]][i] = Piece.new vals[0], pieces[i] #pos display is [+1, (+97).chr]
      end
    end

    @black_king_position = [0,4]
    @white_king_position = [7,4]
  end

  #Precondition: 'from' is a valid position.
  def available_moves from, check=true
    from_position = text_to_pos(from)
    piece = @board[from_position[0]][from_position[1]]
    moves = []

    case piece.type
    when 'bishop'
      moves = bishop_moves piece.color, from_position
    when 'king'
      moves = king_moves piece.color, from_position
    when 'knight'
      moves = knight_moves piece.color, from_position
    when 'pawn'
      moves = pawn_moves piece.color, from_position
    when 'queen'
      moves = queen_moves piece.color, from_position
    when 'rook'
      moves = rook_moves piece.color, from_position
    end

    if check
      board = @board.map { |arr| arr.map(&:clone) }
      wkp = @white_king_position
      bkp = @black_king_position
      final_moves = moves.select do |to|
        move(from, to, false)
        answer = !in_check?(piece.color)
        @board = board.map { |arr| arr.map(&:clone) }
        @white_king_position = wkp
        @black_king_position = bkp
        answer
      end
      final_moves
    else
      moves
    end
  end

  def display
    counter = 0
    puts "  " + "  a b c d e f g h   ".bg_red
    @board.each_with_index do |row, i| 
      print "  " + "#{i + 1} ".bg_red 
      row.each do |spot|
        square = spot.to_s
        if spot.is_a?(Piece) && !spot.color
          square = square.black
        end
        print counter % 2 == 0 ? square.bg_blue : square.bg_brown
        counter += 1
      end 
      puts " #{i + 1}".bg_red
      counter += 1
    end
    puts "  " + "  a b c d e f g h   ".bg_red
  end

  def in_check? color
    opponents = []
    board = @board.map { |arr| arr.map(&:clone) }
    board.each_with_index do |v, i|
      v.each_with_index do |opponent, j|
        position = pos_to_text(i, j)
        if opponent.is_a?(Piece) && opponent.color != color
          opponents << position
        end
      end
    end
    king_pos = color ? pos_to_text(@white_king_position[0], @white_king_position[1]) : pos_to_text(@black_king_position[0], @black_king_position[1])

  
    opponents.each do |opponent| 
      moves = available_moves(opponent, false)
      return true if moves.include?(king_pos)
    end
    false
  end

  #Precondition: 'from' and 'to' are valid positions.
  def move from, to, legit = true
    from_pos = text_to_pos(from)
    to_pos = text_to_pos(to)
    piece = @board[from_pos[0]][from_pos[1]]
    if piece.type == 'king'
      piece.color ? @white_king_position = to_pos : @black_king_position = to_pos
    end
    @board[from_pos[0]][from_pos[1]] = '  '
    @board[to_pos[0]][to_pos[1]] = piece

    if legit && piece.type == 'pawn' && ((piece.color && to_pos[0] == 0) || (!piece.color && to_pos[0] == 7))
      promote(to)
    end
  end

  #Return the positions of all the pieces of a color.
  def piece_spots color
    spots = []
    board = @board.map { |arr| arr.map(&:clone) }
    board.each_with_index do |v, i|
      v.each_with_index do |spot, j|
        position = pos_to_text(i, j)
        spots << position if spot.is_a?(Piece) && (spot.color == color) && !available_moves(position).empty?
      end
    end
    spots
  end
  # to test certain things
  def set_up
    @board = Array.new(8) { Array.new(8, '  ') }
    @white_king_position = [7,0]
    @board[7][0] = Piece.new(true, 'king')
    @board[0][0] = Piece.new(false, 'rook')
    @board[0][1] = Piece.new(false, 'rook')
  end

  private

  def check_diagonal_bottom color, pos, moves, left_right
    spot = @board[pos[0]].nil? ? nil : @board[pos[0]][pos[1]]
    if pos[0] < 0 || pos[0] > 7 || pos[1] < 0 || pos[1] > 7
      moves
    elsif spot == "  "
      moves << pos_to_text(pos[0], pos[1])
      check_diagonal_bottom(color, [pos[0] + 1, pos[1] + left_right], moves, left_right)
    else 
      moves << pos_to_text(pos[0], pos[1]) if spot.color != color
      moves
    end
  end

  def check_diagonal_top color, pos, moves, left_right
    spot = @board[pos[0]].nil? ? nil : @board[pos[0]][pos[1]]
    if pos[0] < 0 || pos[0] > 7 || pos[1] < 0 || pos[1] > 7
      moves
    elsif spot == "  "
      moves << pos_to_text(pos[0], pos[1])
      check_diagonal_top(color, [pos[0] - 1, pos[1] + left_right], moves, left_right)
    else 
      moves << pos_to_text(pos[0], pos[1]) if spot.color != color
      moves
    end
  end

  #left_right is 1 or -1
  def check_horizontal color, pos, moves, left_right
    spot = @board[pos[0]].nil? ? nil : @board[pos[0]][pos[1]]
    if pos[0] < 0 || pos[0] > 7 || pos[1] < 0 || pos[1] > 7
      moves
    elsif spot == "  "
      moves << pos_to_text(pos[0], pos[1])
      check_horizontal(color, [pos[0], pos[1] + left_right], moves, left_right)
    else 
      moves << pos_to_text(pos[0], pos[1]) if spot.color != color
      moves
    end
  end

  #up_down is 1 or -1
  def check_vertical color, pos, moves, up_down
    spot = @board[pos[0]].nil? ? nil : @board[pos[0]][pos[1]]
    if pos[0] < 0 || pos[0] > 7 || pos[1] < 0 || pos[1] > 7
      moves
    elsif spot == "  "
      moves << pos_to_text(pos[0], pos[1])
      check_vertical(color, [pos[0] + up_down, pos[1]], moves, up_down)
    else 
      moves << pos_to_text(pos[0], pos[1]) if spot.color != color
      moves
    end
  end

  def bishop_moves color, pos
    moves = []
    check_diagonal_bottom(color, [pos[0] + 1, pos[1] + 1], moves, 1)
    check_diagonal_bottom(color, [pos[0] + 1, pos[1] - 1], moves, -1)
    check_diagonal_top(color, [pos[0] - 1, pos[1] + 1], moves, 1)
    check_diagonal_top(color, [pos[0] - 1, pos[1] - 1], moves, -1)
    moves
  end

  def king_moves color, pos
    moves = []
    spot = @board[pos[0]][pos[1]]
      
    down_valid = pos[0] < 7 
    up_valid = pos[0] > 0 
    left_valid = pos[1] > 0 
    right_valid = pos[1] < 7
    dl_valid = down_valid && left_valid
    dr_valid = down_valid && right_valid
    ul_valid = up_valid && left_valid
    ur_valid = up_valid && right_valid

    adjacent = right_valid ? @board[pos[0]][pos[1] + 1] : false
    moves << pos_to_text(pos[0], pos[1] + 1) if adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = left_valid ? @board[pos[0]][pos[1] - 1] : false
    moves << pos_to_text(pos[0], pos[1] - 1) if adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = down_valid ? @board[pos[0] + 1][pos[1]] : false
    moves << pos_to_text(pos[0] + 1, pos[1]) if  adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = up_valid ? @board[pos[0] - 1][pos[1]] : false
    moves << pos_to_text(pos[0] - 1, pos[1]) if adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = dr_valid ? @board[pos[0] + 1][pos[1] + 1] : false
    moves << pos_to_text(pos[0] + 1, pos[1] + 1) if adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = dl_valid ? @board[pos[0] + 1][pos[1] - 1] : false
    moves << pos_to_text(pos[0] + 1, pos[1] - 1) if adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = ur_valid ? @board[pos[0] - 1][pos[1] + 1] : false
    moves << pos_to_text(pos[0] - 1, pos[1] + 1) if adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = ul_valid ? @board[pos[0] - 1][pos[1] - 1] : false
    moves << pos_to_text(pos[0] - 1, pos[1] - 1) if adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    moves
  end

  def knight_moves color, pos
    moves = []
    spot = @board[pos[0]][pos[1]]  

    up_one = pos[0] > 0 
    up_two = pos[0] - 2 >= 0
    down_one = pos[0] < 7
    down_two = pos[0] + 2 <= 7
    left_one = pos[1] > 0
    left_two = pos[1] - 2 >= 0
    right_one = pos[1] < 7
    right_two = pos[1] + 2 <= 7

    adjacent = @board[pos[0] + 1].nil? ? nil : @board[pos[0] + 1][pos[1] - 2]
    moves << pos_to_text(pos[0] + 1, pos[1] - 2) if down_one && left_two && adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = @board[pos[0] + 2].nil? ? nil : @board[pos[0] + 2][pos[1] - 1]
    moves << pos_to_text(pos[0] + 2, pos[1] - 1) if down_two && left_one && adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = @board[pos[0] + 2].nil? ? nil : @board[pos[0] + 2][pos[1] + 1]
    moves << pos_to_text(pos[0] + 2, pos[1] + 1) if down_two && right_one && adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = @board[pos[0] + 1].nil? ? nil : @board[pos[0] + 1][pos[1] + 2]
    moves << pos_to_text(pos[0] + 1, pos[1] + 2) if down_one && right_two && adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = @board[pos[0] - 1].nil? ? nil : @board[pos[0] - 1][pos[1] - 2]
    moves << pos_to_text(pos[0] - 1, pos[1] - 2) if up_one && left_two && adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = @board[pos[0] - 2].nil? ? nil : @board[pos[0] - 2][pos[1] - 1]
    moves << pos_to_text(pos[0] - 2, pos[1] - 1) if up_two && left_one && adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = @board[pos[0] - 2].nil? ? nil : @board[pos[0] - 2][pos[1] + 1]
    moves << pos_to_text(pos[0] - 2, pos[1] + 1) if up_two && right_one && adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    adjacent = @board[pos[0] - 1].nil? ? nil : @board[pos[0] - 1][pos[1] + 2]
    moves << pos_to_text(pos[0] - 1, pos[1] + 2) if up_one && right_two && adjacent && (adjacent == '  ' || adjacent.color !=  spot.color)
    moves
  end

  def pawn_moves color, pos
    moves = []
    i = color ? 1 : -1
    #normal move
    moves << pos_to_text(pos[0] - i, pos[1]) if !@board[pos[0] - i].nil? && pos[0] - i != -1 && @board[pos[0] - i][pos[1]] == '  '
    #double initial move
    moves << pos_to_text(pos[0] - (2 * i), pos[1]) if ((color && (pos[0] == 6)) || (!color && (pos[0] == 1))) && (moves.length) == 1 && (@board[pos[0] - (2 * i)][pos[1]] == '  ')
    #attack left or right - depends on i
    moves << pos_to_text(pos[0] - i, pos[1] + i) if !@board[pos[0] - i].nil? && pos[0] - i != -1 && @board[pos[0] - i][pos[1] + i].is_a?(Piece) && @board[pos[0] - i][pos[1] + i].color != color
    #attack left or right - depends on i
    moves << pos_to_text(pos[0] - i, pos[1] - i) if !@board[pos[0] - i].nil? && pos[0] - i != -1 && pos[1] - 1 != -1 && @board[pos[0] - i][pos[1] - i].is_a?(Piece) && @board[pos[0] - i][pos[1] - i].color != color
    #TO BE IMPLEMENTED en passant left or right
    moves
  end

  def pos_to_text r, c
    (c+97).chr + "#{r + 1}"
  end

  def promote spot
    pos = text_to_pos(spot)
    puts "Choose a piece to promote your pawn to: knight, rook, bishop, queen"
    answer = gets.chomp.downcase
    while !['knight', 'rook', 'bishop', 'queen'].include?(answer)
      puts "Enter a valid option"
      answer = gets.chomp.downcase
    end
    @board[pos[0]][pos[1]] = Piece.new(pos[0] == 0, answer)
  end

  def queen_moves color, pos
    moves = []
    moves += bishop_moves(color, pos)
    moves += rook_moves(color, pos)
    moves
  end

  def rook_moves color, pos
    moves = []
    check_vertical(color, [pos[0] + 1, pos[1]], moves, 1)
    check_vertical(color, [pos[0] - 1, pos[1]], moves, -1)
    check_horizontal(color, [pos[0], pos[1] + 1], moves, 1)
    check_horizontal(color, [pos[0], pos[1] - 1], moves, -1)
    moves
  end

  def text_to_pos text
    [text[1].to_i - 1, text[0].ord - 97]
  end
end

=begin
a = Board.new
#a.set_up
300.times do |i|
  a.display
  moveables = a.piece_spots(i % 2 == 0)
  break if moveables.empty?
  chosen = moveables.sample
  a.move(chosen, a.available_moves(chosen).sample)
  sleep(0.1)
  system("clear")
end
a.display
=end
