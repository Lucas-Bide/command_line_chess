class Piece
  attr_accessor :type, :en_passant
  attr_reader :color
  
  def initialize color, type
    @color = color # true for white, false for black
    @type = type
    @en_passant = nil
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
