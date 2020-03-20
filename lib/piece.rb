class Piece
  attr_accessor :unmoved
  attr_reader :color, :type 
  
  def initialize color, type
    @color = color # true for white, false for black
    @type = type
    @unmoved = true
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
end
