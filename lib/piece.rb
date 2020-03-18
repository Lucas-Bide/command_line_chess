class Piece
  attr_accessor :type, :position
  attr_reader :color
  
  def initialize color, type, position
    @color = color # true for white, false for black
    @type = type
    @position = position
  end

  def to_s
    # ♔ ♕ ♖ ♗ ♘ ♙ 
    # ♚ ♛ ♜ ♝ ♞ ♟
    case type
    when 'pawn'
      "♟ "
    when 'rook' 
      "♜ "
    when 'knight'
      "♞ "
    when 'bishop'
      "♝ "
    when 'king'
      "♚ "
    when 'queen'
      "♛ "
    end
  end
=begin
    when 'pawn'
      @color ? "♟ " : "♙ "
    when 'rook' 
      @color ? "♜ " : "♖ "
    when 'knight'
      @color ? "♞ " : "♘ "
    when 'bishop'
      @color ? "♝ " : "♗ "
    when 'king'
      @color ? "♚ " : "♔ "
    when 'queen'
      @color ? "♛ " : "♕ "
    end
  end
=end
end
