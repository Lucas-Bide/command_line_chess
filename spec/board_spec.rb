require './lib/board.rb'
require './lib/piece.rb'
require 'rspec'

RSpec.describe Board do
  describe "#available_moves" do
    before(:each) do
      @board = Board.new
      @mock_board = Array.new(8) { Array.new(8, '  ') }
      @board.instance_variable_set(:@board, @mock_board)
      @board.instance_variable_set(:@white_king_position, [7, 0])
      @board.instance_variable_set(:@black_king_position, [7, 2])
    end

    context 'basics' do
      it "should return the rook's moves" do
        @mock_board[4][0] = Piece.new(true, 'pawn')
        @mock_board[1][4] = Piece.new(false, 'pawn')
        @mock_board[4][4] = Piece.new(true, 'rook')
        expect(@board.available_moves('e5').sort).to eql(['b5','c5','d5','f5','g5','h5','e8','e7','e6','e4','e3','e2'].sort)
      end

      it "should return the bishop's moves" do
        @mock_board[0][0] = Piece.new(false, 'pawn')
        @mock_board[7][1] = Piece.new(true, 'pawn')
        @mock_board[4][4] = Piece.new(false, 'bishop')
        expect(@board.available_moves('e5').sort).to eql(['b2','c3','d4','d6','c7','b8','f4','g3','h2','f6','g7','h8'].sort)
      end

      it "should return the knight's moves" do
        @mock_board[2][2] = Piece.new(false, 'pawn')
        @mock_board[3][3] = Piece.new(true, 'pawn')
        @mock_board[4][1] = Piece.new(true, 'knight')
        expect(@board.available_moves('b5').sort).to eql(['a7','c7','d6','c3','a3'].sort)
      end

      it "should return the queen's moves" do
        @mock_board[4][0] = Piece.new(true, 'pawn')
        @mock_board[1][4] = Piece.new(false, 'pawn')
        @mock_board[0][0] = Piece.new(false, 'pawn')
        @mock_board[7][1] = Piece.new(true, 'pawn')
        @mock_board[4][4] = Piece.new(true, 'queen')
        expect(@board.available_moves('e5').sort).to eql(['b5','c5','d5','f5','g5','h5','e8','e7','e6','e4','e3','e2','b2','c3','d4','d6','c7','f4','g3','h2','f6','g7','h8','a1'].sort)
      end

      it "should return the king's moves" do
        @board.instance_variable_set(:@white_king_position, [3,7])
        @mock_board[2][6] = Piece.new(false, 'pawn')
        @mock_board[4][6] = Piece.new(true, 'pawn')
        @mock_board[3][7] = Piece.new(true, 'king')
        expect(@board.available_moves('h4').sort).to eql(['h3','h5','g3','g4'].sort)
      end

      it "should return the pawn's moves" do
        @mock_board[5][4] = Piece.new(false, 'pawn')
        @mock_board[6][5] = Piece.new(true, 'pawn')
        expect(@board.available_moves('f7').sort).to eql(['e6','f6','f5'].sort)
      end
    end

    context "en passant" do
      it "should return e.p. for pawn" do
        @mock_board[1][3] = Piece.new(false, 'pawn')
        @mock_board[3][2] = Piece.new(true, 'pawn')
        @board.move('d2', 'd4')
        expect(@board.available_moves('c4')).to include('d3')
      end

      it "shouldn't return e.p. for edge pawn" do
        @mock_board[1][0] = Piece.new(false, 'pawn')
        @mock_board[3][7] = Piece.new(true, 'pawn')
        @board.move('a2', 'a4')
        expect(@board.available_moves('h4')).not_to include('a3')
      end
    end

    context "castling" do
      it "should return the castling option in under castling conditions" do
      @black_king_position = [0,4]  
      @mock_board[0][0] = Piece.new(false, 'rook')
      @mock_board[0][4] = Piece.new(false, 'king')
      expect(@board.available_moves('e1')).to include('c1')
      end

      it "shouldn't return the castling option if a piece has moved" do
        @board.instance_variable_set(:@black_king_position, [0,4])
        @mock_board[0][7] = Piece.new(false, 'rook')
        @mock_board[0][4] = Piece.new(false, 'king')
        @board.move('e1', 'e2')
        @board.move('e2', 'e1')
        expect(@board.available_moves('e1')).not_to include('g1')
      end

      it "shouldn't return the castling option if the king would undergo check" do
        @black_king_position = [0,4]  
        @mock_board[0][7] = Piece.new(false, 'rook')
        @mock_board[0][4] = Piece.new(false, 'king')
        @mock_board[2][5] = Piece.new(true, 'rook')
        expect(@board.available_moves('e1')).not_to include('g1')
      end
    end
  end

  describe "#piece_spots" do
    before(:each) do
      @board = Board.new
      @mock_board = Array.new(8) { Array.new(8, '  ') }
      @board.instance_variable_set(:@board, @mock_board)
      @board.instance_variable_set(:@white_king_position, [7,0])
      @board.instance_variable_set(:@black_king_position, [7, 2])
    end

    context "while in check" do
      it "should return only the pieces that when moved uncheck the king" do
        @board.instance_variable_set(:@white_king_position, [6, 4])
        @mock_board[2][4] = Piece.new(false, 'rook')
        @mock_board[4][1] = Piece.new(false, 'bishop')
        @mock_board[7][3] = Piece.new(false, 'bishop')
        @mock_board[5][3] = Piece.new(true, 'rook')
        @mock_board[5][5] = Piece.new(true, 'pawn')
        @mock_board[6][4] = Piece.new(true, 'king')
        expect(@board.piece_spots(true).sort).to eql(['e7'].sort)
      end
    end

    context "while in checkmate" do #copy above and add queen : empty arr
      it "should return an empty array" do
        @board.instance_variable_set(:@white_king_position, [6, 4])
        @mock_board[2][4] = Piece.new(false, 'rook')
        @mock_board[4][1] = Piece.new(false, 'bishop')
        @mock_board[7][3] = Piece.new(false, 'bishop')
        @mock_board[7][4] = Piece.new(false, 'queen')
        @mock_board[5][3] = Piece.new(true, 'rook')
        @mock_board[5][5] = Piece.new(true, 'pawn')
        @mock_board[6][4] = Piece.new(true, 'king')
        expect(@board.piece_spots(true)).to eql([])
      end
    end
      #context stalemate
  end
end
