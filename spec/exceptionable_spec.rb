# frozen_string_literal: true

RSpec.describe Exceptionable do
  let(:game) { Game.new }

  matcher :be_file do
    match { |p| p.current_position[0] }
  end

  before do
    Player.player_count = 0
    Board.board_count = 0
    allow_any_instance_of(Human).to receive(:make_choice).and_return("2\n")

    allow($stdout).to receive(:write)
  end

  describe '#check_mate?' do
    context 'when the game first starts' do
      it 'returns false' do
        expect(game.check_mate?(game.player2)).to be(false)
      end
    end

    context 'when the king of the second player is checked' do
      before do
        0.upto(7) do |idx|
          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end

          unless [4].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil

            game.board.layout[6][idx].current_position = nil
            game.board.layout[6][idx] = nil
          end
        end

        game.board.layout[2][1] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[2][1].current_position = [2, 1]

        game.board.layout[2][2] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[2][2].current_position = [2, 2]

        game.board.layout[2][0] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][0].current_position = [2, 0]

        game.board.layout[0][0] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[0][0].current_position = [0, 0]
        game.board.layout[0][0].checked_positions = [[1, 0], [1, 1], [0, 1]]
      end

      it 'returns all possible moves that non-pawn pieces of the first player can make' do
        expect(game.check_mate?(game.player1)).to be(true)
      end
    end

  end

  describe '#check_now?' do
    context 'when the game first starts' do
      it 'returns false' do
        expect(game.check_now?(game.player2)).to be(false)
      end
    end

    context 'when the king of the second player is checked' do
      before do
        0.upto(7) do |idx|
          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end

          unless [4].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil

            game.board.layout[6][idx].current_position = nil
            game.board.layout[6][idx] = nil
          end
        end

        game.board.layout[2][1] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[2][1].current_position = [2, 1]

        game.board.layout[2][2] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[2][2].current_position = [2, 2]

        game.board.layout[2][0] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][0].current_position = [2, 0]

        game.board.layout[0][0] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[0][0].current_position = [0, 0]
        game.board.layout[0][0].checked_positions = [[1, 0], [1, 1], [0, 1]]
      end

      it 'returns true' do
        expect(game.check_now?(game.player1)).to be(true)
      end
    end
  end

  describe '#check_next?' do
    context 'when the game first starts' do
      it 'returns false' do
        expect(game.check_next?(game.player1)).to be(false)
      end
    end

    context 'when the king of the second player is checked' do
      before do
        0.upto(7) do |idx|
          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end

          unless [4].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil

            game.board.layout[6][idx].current_position = nil
            game.board.layout[6][idx] = nil
          end
        end

        game.board.layout[2][1] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[2][1].current_position = [2, 1]

        game.board.layout[2][2] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[2][2].current_position = [2, 2]

        game.board.layout[2][0] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][0].current_position = [2, 0]

        game.board.layout[0][0] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[0][0].current_position = [0, 0]
        game.board.layout[0][0].checked_positions = [[1, 0], [1, 1], [0, 1]]
      end

      it 'returns true' do
        expect(game.check_next?(game.player1)).to be(true)
      end
    end
  end

  describe '#opponent_next_moves' do
    context 'when the game first starts' do
      it 'returns all possible moves that opponent pieces of the second player can make' do
        expect(game.non_pawn_next_moves(game.player2)).to be_empty
      end
    end

    context 'when the king of the second player is checked' do
      before do
        0.upto(7) do |idx|
          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end

          unless [4].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil

            game.board.layout[6][idx].current_position = nil
            game.board.layout[6][idx] = nil
          end
        end

        game.board.layout[2][1] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[2][1].current_position = [2, 1]

        game.board.layout[2][2] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[2][2].current_position = [2, 2]

        game.board.layout[2][0] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][0].current_position = [2, 0]

        game.board.layout[0][0] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[0][0].current_position = [0, 0]
        game.board.layout[0][0].checked_positions = [[1, 0], [1, 1], [0, 1]]
      end

      it 'returns all possible moves that pieces of the first player can make' do
        checked_moves = [[1, 0], [1, 1], [0, 1], [5, 5], [4, 6], [3, 7], [2, 8], [5, 3]]
        expect((checked_moves - game.opponent_next_moves(game.player1)).empty?).to eq(true)
      end
    end
  end

  describe '#non_pawn_next_moves' do
    context 'when the game first starts' do
      it 'returns all possible moves that non-pawn pieces of the first player can make' do
        expect(game.non_pawn_next_moves(game.player1)).to be_empty
      end
    end

    context 'when the king of the second player is checked' do
      before do
        0.upto(7) do |idx|
          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          game.board.layout[6][idx].current_position = nil
          game.board.layout[6][idx] = nil

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil
          end

          unless [4].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        game.board.layout[5][5] = game.board.layout[0][1]
        game.board.layout[0][1] = nil
        game.board.layout[5][5].current_position = [5, 5]

        game.board.layout[5][6] = game.board.layout[0][6]
        game.board.layout[0][6] = nil
        game.board.layout[5][6].current_position = [5, 6]

        game.board.layout[5][7] = game.board.layout[0][3]
        game.board.layout[0][3] = nil
        game.board.layout[5][7].current_position = [5, 7]

        game.board.layout[7][7] = game.board.layout[7][4]
        game.board.layout[7][4] = nil
        game.board.layout[7][7].current_position = [7, 7]
        game.board.layout[7][7].checked_positions = [[6, 7], [6, 6], [7, 6]]
      end

      it 'returns all possible moves that non-pawn pieces of the first player can make' do
        checked_moves = [[6, 7], [6, 6], [7, 6]]
        expect((checked_moves - game.non_pawn_next_moves(game.player2)).empty?).to eq(true)
      end
    end
  end

  describe '#pawn_next_moves' do
    context 'when the game first starts' do
      it 'returns all possible moves that pawns of the first player can make' do
        next_moves = [
          [5, 1], [4, 2], [3, 3], [2, 4], [1, 5], [0, 6], [-1, 7], [5, -1], [5, 2], [4, 3],
          [3, 4], [2, 5], [1, 6], [0, 7], [-1, 8], [5, 0], [5, 3], [4, 4], [3, 5], [2, 6],
          [1, 7], [0, 8], [5, 4], [4, 5], [3, 6], [2, 7], [1, 8], [5, 5], [4, 6], [3, 7],
          [2, 8], [5, 6], [4, 7], [3, 8], [5, 7], [4, 8], [5, 8]
        ]
        expect((next_moves - game.pawn_next_moves(game.player1)).empty?).to be(true)
      end
    end

    context 'when the game first starts' do
      it 'returns all possible moves that pawns of the second player can make' do
        next_moves = [
          [2, -1], [2, 1], [2, 0], [3, -1], [2, 2], [3, 0], [4, -1], [2, 3], [3, 1], [4, 0],
          [5, -1], [2, 4], [3, 2], [4, 1], [5, 0], [6, -1], [2, 5], [3, 3], [4, 2], [5, 1],
          [6, 0], [7, -1], [2, 6], [3, 4], [4, 3], [5, 2], [6, 1], [7, 0], [8, -1], [2, 7],
          [3, 5], [4, 4], [5, 3], [6, 2], [7, 1], [8, 0], [2, 8]
        ]
        expect((next_moves - game.pawn_next_moves(game.player2)).empty?).to be(true)
      end
    end
  end

  describe '#checked_moves' do
    context 'when the game first begins' do
      it 'returns an empty array (no checked moves)' do
        expect(game.checked_moves(game.player1)).to be_empty
      end
    end

    context 'when the king of the second player is checked' do
      before do
        0.upto(7) do |idx|
          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          game.board.layout[6][idx].current_position = nil
          game.board.layout[6][idx] = nil

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil
          end

          unless [4].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        game.board.layout[5][5] = game.board.layout[0][1]
        game.board.layout[0][1] = nil
        game.board.layout[5][5].current_position = [5, 5]

        game.board.layout[5][6] = game.board.layout[0][6]
        game.board.layout[0][6] = nil
        game.board.layout[5][6].current_position = [5, 6]

        game.board.layout[5][7] = game.board.layout[0][3]
        game.board.layout[0][3] = nil
        game.board.layout[5][7].current_position = [5, 7]

        game.board.layout[7][7] = game.board.layout[7][4]
        game.board.layout[7][4] = nil
        game.board.layout[7][7].current_position = [7, 7]
      end

      it 'contains the positions [6, 7], [6, 6], [7, 6]' do
        result = game.checked_moves(game.player2)
        expect((result - [[6, 7], [6, 6], [7, 6]]).empty?).to be(true)
      end
    end
  end

  describe '#checked?' do
    context 'when the fifth pawn of the first player is at f7' do
      before do
        game.board.layout[6][5].current_position = nil
        game.board.layout[6][5] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[6][5].current_position = [6, 5]
      end
      it 'returns a pawn with a current position of f7' do
        piece = game.checked?([7, 4], game.player2)[0]
        expect(piece).to be_a(Pawn)
        expect(piece.current_position).to eq([6, 5])
      end
    end

    context 'when the game first starts' do
      it 'returns nil' do
        piece = game.checked?([7, 4], game.player2)[0]
        expect(piece).to be_nil
      end
    end
  end

  describe '#opponent_pawns' do
    context 'when the first player is selected' do
      it 'returns the pawn pieces of the second player' do
        opp = game.opponent_pawns(game.player1)
        expect(opp).to all(be_a(Pawn))
        expect(opp).to all(be_file(6))
      end
    end

    context 'when the second player is selected' do
      it 'returns the pawn pieces of the first player' do
        opp = game.opponent_pawns(game.player2)
        expect(opp).to all(be_a(Pawn))
        expect(opp).to all(be_file(1))
      end
    end
  end

  describe '#opponent' do
    context 'when the first player is selected' do
      it 'returns the second player' do
        expect(game.opponent(game.player1)).to be(game.player2)
      end
    end

    context 'when the second player is selected' do
      it 'returns the first player' do
        expect(game.opponent(game.player2)).to be(game.player1)
      end
    end
  end

  describe '#promotion' do
    context 'when a queen is selected for the promotion at d7' do
      it 'returns a queen piece and a total of 2 queens' do
        move_elements = ['', '', '', 'd7', '=Q', nil]
        expect(game.promotion(PIECE_STATS, move_elements, game.player1)).to be_a(Queen)
        expect(game.player1.queen.count).to eq(2)
      end
    end

    context 'when a bishop is selected for the promotion at h7 and one of the bishops is captured' do
      it 'returns a queen piece and a total of 2 bishops (the captured one is promoted)' do
        game.player1.bishop[1].current_position = nil
        move_elements = ['', '', '', 'h7', '=B', nil]
        expect(game.promotion(PIECE_STATS, move_elements, game.player1)).to be_a(Bishop)
        expect(game.player1.bishop.count).to eq(2)
      end
    end

    context 'when a bishop is selected for the promotion at h7 and one of the bishops is captured' do
      it 'returns a queen piece and a total of 2 bishops (the captured one is promoted)' do
        game.player1.bishop[1].current_position = nil
        move_elements = ['', '', '', 'h7', '=B', nil]
        expect(game.promotion(PIECE_STATS, move_elements, game.player1)).to be_a(Bishop)
        expect(game.player1.bishop.count).to eq(2)
      end
    end

    context 'when a promoted piece is randomly selected by the computer' do
      it 'returns a piece of either rook, bishop, knight, or queen' do
        promoted_pieces = [Rook, Bishop, Knight, Queen]
        expect(promoted_pieces.include?(game.promotion(PIECE_STATS, nil, game.player2).class)).to be(true)
      end
    end
  end


  describe '#promotable?' do
    context 'when the third pawn of player 1 is not at the promotable position' do
      it 'returns false' do
        expect(game.promotable?(game.player1.pawn[2])).to be(false)
      end
    end

    context 'when the third pawn of player 1 is at the promotable position' do
      before do
        game.board.layout[6][2] = game.board.layout[1][2]
        game.board.layout[1][2] = nil
        game.board.layout[6][2].current_position = [6, 2]
      end
      it 'returns true' do
        expect(game.promotable?(game.player1.pawn[2])).to be(true)
      end
    end

    context 'when the first knight of player 2 is selected' do
      it 'returns false' do
        expect(game.promotable?(game.player2.knight[0])).to be(false)
      end
    end

    context 'when the last pawn of player 2 is at the promotable position' do
      before do
        game.board.layout[1][7] = game.board.layout[6][7]
        game.board.layout[6][7] = nil
        game.board.layout[1][7].current_position = [1, 7]
      end
      it 'returns true' do
        expect(game.promotable?(game.player2.pawn[7])).to be(true)
      end
    end
  end

  describe '#en_passant?' do
    context 'when the first player moves the fourth pawn to e4' do
      it 'returns false' do
        expect(game.en_passant?(game.player1, [4, 3])).to be(false)
      end
    end

    context 'when the pawn at e5 captures the opponent pawn at f5' do
      before do
        game.board.layout[4][4] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[4][4].current_position = [4, 4]

        game.board.layout[4][5] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[4][5].current_position = [4, 5]
        game.board.layout[4][5].double_step[1] = true
      end
      it 'returns true' do
        expect(game.en_passant?(game.player1, [5, 5])).to be(true)
      end
    end

    context 'when the pawn at h4 captures the opponent pawn at g4' do
      before do
        game.board.layout[3][7] = game.board.layout[6][7]
        game.board.layout[6][7] = nil
        game.board.layout[3][7].current_position = [3, 7]

        game.board.layout[3][6] = game.board.layout[1][6]
        game.board.layout[1][6] = nil
        game.board.layout[3][6].current_position = [3, 6]
        game.board.layout[3][6].double_step[1] = true
      end
      it 'returns true' do
        expect(game.en_passant?(game.player2, [2, 6])).to be(true)
      end
    end
  end

  describe '#negate_en_passant' do
    context 'when the first player\'s pawn on file h is selected' do
      it 'returns false' do
        expect(game.negate_en_passant(game.player1.pawn[7])).to be(false)
      end
    end

    context 'when the second player\'s pawn on file e which is captured is selected' do
      it 'returns true' do
        game.player2.pawn[7].current_position = nil
        expect(game.negate_en_passant(game.player2.pawn[7])).to be(true)
      end
    end

    context 'when the first player\'s second queen which does not exist is selected' do
      it 'returns true' do
        expect(game.negate_en_passant(game.player1.queen[1])).to be(true)
      end
    end
  end

  describe '#prove_en_passant' do
    context 'when the first player selects the knight piece on the queen side' do
      it 'returns false' do
        expect(game.prove_en_passant(game.player1.knight[0], game.player1, [2, 2])).to be(false)
      end
    end

    context 'when the second player selects the knight piece on the king side' do
      it 'returns false' do
        expect(game.prove_en_passant(game.player1.knight[1], game.player1, [2, 7])).to be(false)
      end
    end

    context 'when the pawn at e5 captures the opponent pawn at f5' do
      before do
        game.board.layout[4][4] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[4][4].current_position = [4, 4]

        game.board.layout[4][5] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[4][5].current_position = [4, 5]
        game.board.layout[4][5].double_step[1] = true
      end
      it 'returns true' do
        expect(game.prove_en_passant(game.player2.pawn[4], game.player1, [4, 4])).to be(true)
      end
    end

    context 'when the pawn at h4 captures the opponent pawn at g4' do
      before do
        game.board.layout[3][7] = game.board.layout[6][7]
        game.board.layout[6][7] = nil
        game.board.layout[3][7].current_position = [3, 7]

        game.board.layout[3][6] = game.board.layout[1][6]
        game.board.layout[1][6] = nil
        game.board.layout[3][6].current_position = [3, 6]
        game.board.layout[3][6].double_step[1] = true
      end
      it 'returns the first player\'s sixth pawn' do
        expect(game.prove_en_passant(game.player1.pawn[5], game.player2, [3, 5])).to be(true)
      end
    end
  end

  describe '#en_passant_eligible' do
    context 'when the game first starts' do
      it 'returns nil' do
        expect(game.en_passant_eligible(game.player1)).to be_nil
        expect(game.en_passant_eligible(game.player2)).to be_nil
      end
    end

    context 'when the pawn at e5 captures the opponent pawn at f5' do
      before do
        game.board.layout[4][4] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[4][4].current_position = [4, 4]

        game.board.layout[4][5] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[4][5].current_position = [4, 5]
        game.board.layout[4][5].double_step[1] = true
      end
      it 'returns the second player\'s fifth pawn' do
        target = game.en_passant_eligible(game.player1)
        expect(target.current_position).to eq([4, 5])
        expect(target).to eq(game.player2.pawn[5])
      end
    end

    context 'when the pawn at h4 captures the opponent pawn at g4' do
      before do
        game.board.layout[3][7] = game.board.layout[6][7]
        game.board.layout[6][7] = nil
        game.board.layout[3][7].current_position = [3, 7]

        game.board.layout[3][6] = game.board.layout[1][6]
        game.board.layout[1][6] = nil
        game.board.layout[3][6].current_position = [3, 6]
        game.board.layout[3][6].double_step[1] = true
      end
      it 'returns the first player\'s sixth pawn' do
        target = game.en_passant_eligible(game.player2)
        expect(target.current_position).to eq([3, 6])
        expect(target).to eq(game.player1.pawn[6])
      end
    end
  end

  describe '#en_passant_opponent' do
    context 'when the pawn at d2 moves to d3' do
      it 'returns nil' do
        expect(game.en_passant_opponent(game.player1, [3, 3])).to be_nil
      end
    end

    context 'when the pawn at e5 captures the opponent pawn at f5' do
      before do
        game.board.layout[4][4] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[4][4].current_position = [4, 4]

        game.board.layout[4][5] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[4][5].current_position = [4, 5]
      end
      it 'returns [4, 5]' do
        target = game.en_passant_opponent(game.player1, [5, 5])
        expect(target).to be_a(Pawn)
        expect(target.current_position).to eq([4, 5])
      end
    end

    context 'when the pawn at h4 captures the opponent pawn at g4' do
      before do
        game.board.layout[3][7] = game.board.layout[6][7]
        game.board.layout[6][7] = nil
        game.board.layout[3][7].current_position = [3, 7]

        game.board.layout[3][6] = game.board.layout[1][6]
        game.board.layout[1][6] = nil
        game.board.layout[3][6].current_position = [3, 6]
      end
      it 'returns [3, 6]' do
        target = game.en_passant_opponent(game.player2, [2, 6])
        expect(target).to be_a(Pawn)
        expect(target.current_position).to eq([3, 6])
      end
    end
  end

  describe '#en_passant_target' do
    context 'when the pawn at e2 moves to e4' do
      it 'returns nil' do
        expect(game.en_passant_target(game.player1, [3, 4])).to be_nil
      end
    end

    context 'when the pawn at e5 captures the opponent pawn at f5' do
      before do
        game.board.layout[4][4] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[4][4].current_position = [4, 4]

        game.board.layout[4][5] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[4][5].current_position = [4, 5]
      end
      it 'returns [4, 5]' do
        target = game.en_passant_target(game.player1, [4, 6])
        expect(target).to be_a(Pawn)
        expect(target.current_position).to eq([4, 5])
      end
    end

    context 'when the pawn at h4 captures the opponent pawn at g4' do
      before do
        game.board.layout[3][7] = game.board.layout[6][7]
        game.board.layout[6][7] = nil
        game.board.layout[3][7].current_position = [3, 7]

        game.board.layout[3][6] = game.board.layout[1][6]
        game.board.layout[1][6] = nil
        game.board.layout[3][6].current_position = [3, 6]
      end
      it 'returns [3, 6]' do
        target = game.en_passant_target(game.player2, [3, 5])
        expect(target).to be_a(Pawn)
        expect(target.current_position).to eq([3, 6])
      end
    end
  end

  describe '#en_passant_locations' do
    context 'when the pawn is eligible for en passant is at e5' do
      it 'returns [3, 4]' do
        expect(game.en_passant_locations(game.player1, [4, 4])).to eq([[3, 4]])
      end
    end
  end

  describe '#en_passant_locations' do
    context 'when the pawn is eligible for en passant is at e6' do
      it 'returns [6, 4]' do
        expect(game.en_passant_locations(game.player2, [5, 4])).to eq([[6, 4]])
      end
    end
  end

  describe '#en_passant_pred' do
    context 'when the pawn is eligible for en passant is at e5' do
      it 'returns [[4, 3], [4, 5]]' do
        expect(game.en_passant_prereq([4, 4])).to eq([[4, 3], [4, 5]])
      end
    end

    context 'when the pawn is eligible for en passant is at g5' do
      it 'returns [[4, 5], [4, 7]]' do
        expect(game.en_passant_prereq([4, 6])).to eq([[4, 5], [4, 7]])
      end
    end

  end

  describe '#castling' do
    context 'when the game first starts' do
      it 'returns false for the first player' do
        expect(game.castling?(game.player1.king[0], game.player1.rook[0], game.player1)).to be(false)
      end
    end

    context 'when the path between the king and the rook on the queen side is clear' do
      before do
        [1, 2, 3].each do |idx|
          game.board.layout[0][idx].current_position = nil
          game.board.layout[0][idx] = nil
        end

        game.player1.king[0].castling_type = 'queen_castling'
      end
      context 'Neither the king nor the rook has moved before' do
        it 'returns true' do
          expect(game.castling?(game.player1.king[0], game.player1.rook[0], game.player1)).to be(true)
        end
      end

      context 'when the path between the king and the rook on the queen side is clear but the rook has moved before' do
        before do
          game.player1.rook[0].first_move = false
        end

        it 'returns false' do
          expect(game.castling?(game.player1.king[0], game.player1.rook[0], game.player1)).to be(false)
        end
      end

      context 'when the path between the king and the rook on the queen side is clear but the king has moved before' do
        before do
          game.player1.king[0].first_move = false
        end

        it 'returns false' do
          expect(game.castling?(game.player1.king[0], game.player1.rook[0], game.player1)).to be(false)
        end
      end
    end
  end

  context 'when the game first starts' do
    it 'returns false for the second player' do
      expect(game.castling?(game.player2.king[0], game.player2.rook[1], game.player2)).to be(false)
    end
  end

  context 'when the path between the king and the rook on the king side is clear' do
    before do
      [5, 6].each do |idx|
        game.board.layout[7][idx].current_position = nil
        game.board.layout[7][idx] = nil
      end

      game.player2.king[0].castling_type = 'king_castling'
    end
    context 'Neither the king nor the rook has moved before' do
      it 'returns true' do
        expect(game.castling?(game.player2.king[0], game.player2.rook[1], game.player2)).to be(true)
      end
    end

    context 'when the path between the king and the rook on the queen side is clear but the rook has moved before' do
      before do
        game.player2.rook[1].first_move = false
      end

      it 'returns false' do
        expect(game.castling?(game.player2.king[0], game.player2.rook[1], game.player2)).to be(false)
      end
    end

    context 'when the path between the king and the rook on the queen side is clear but the king has moved before' do
      before do
        game.player2.king[0].first_move = false
      end

      it 'returns false' do
        expect(game.castling?(game.player2.king[0], game.player2.rook[1], game.player2)).to be(false)
      end
    end
  end
end
