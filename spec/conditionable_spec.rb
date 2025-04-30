# frozen_string_literal: true

RSpec.describe Configurable do
  let(:game) { Game.new }

  before do
    Player.player_count = 0
    Board.board_count = 0
    allow_any_instance_of(Human).to receive(:make_choice).and_return("2\n")
    allow($stdout).to receive(:write)
  end

  describe '#valid_promotion?' do
    context 'when the third pawn of player one is at e7 attempts a promotion at f8' do
      before do
        game.board.layout[6][4].current_position = nil
        game.board.layout[6][4] = game.board.layout[1][3]
        game.board.layout[1][3] = nil
        game.board.layout[6][4].current_position = [6, 4]

        game.board.layout[0][0].current_position = nil
        game.board.layout[0][0] = nil
      end

      context 'when it is promotable and the notation is valid' do
        it 'returns true' do
          move = ['', '', '', 'f8', '=R', nil]
          expect(game.valid_promotion?(game.player1.pawn[3], game.player1, move)).to be(true)
        end
      end

      context 'when it is promotable but the notation is invalid' do
        it 'returns true' do
          move = ['', '', '', 'f8', '', nil]
          expect(game.valid_promotion?(game.player1.pawn[3], game.player1, move)).to be(false)
        end
      end

      context 'when it is not promotable but the notation is valid' do
        it 'returns true' do
          move = ['', '', '', 'f8', '=Q', nil]
          expect(game.valid_promotion?(game.player1.pawn[5], game.player1, move)).to be(false)
        end
      end

      context 'when it is not promotable and the notation is invalid' do
        it 'returns false' do
          move = ['N', '', '', 'f8', '=R', nil]
          expect(game.valid_promotion?(game.player1.pawn[5], game.player1, move)).to be(false)
        end
      end

      context 'when it is not promotable and the notation is invalid while the negate filter is on' do
        it 'returns true' do
          move = ['', '', '', '', '', nil]
          expect(game.valid_promotion?(game.player1.pawn[5], game.player1, move, negate: false)).to be(true)
        end
      end
    end

    context 'when the last seventh of player two is at h2 attempts a promotion at g1' do
      before do
        game.board.layout[6][6].current_position = nil
        game.board.layout[1][7] = game.board.layout[6][6]
        game.board.layout[6][6] = nil
        game.board.layout[1][7].current_position = [1, 7]

        game.board.layout[7][3].current_position = nil
        game.board.layout[7][3] = nil
      end

      context 'when it is promotable and the notation is valid' do
        before { allow(game.player2).to receive(:random_destination).and_return([0, 6]) }
        it 'returns true' do
          move = ['', '', '', 'g1', '=Q', nil]
          expect(game.valid_promotion?(game.player2.pawn[6], game.player2, move)).to be(true)
        end
      end

      context 'when it is not promotable but the notation is valid' do
        before { allow(game.player2).to receive(:random_destination).and_return([0, 6]) }
        it 'returns true' do
          move = ['', '', '', 'f8', '=Q', nil]
          expect(game.valid_promotion?(game.player2.pawn[3], game.player2, move)).to be(false)
        end
      end

      context 'when it is not promotable and the notation is invalid' do
        before { allow(game.player2).to receive(:random_destination).and_return([4, 9]) }
        move = ['', '', '', '', '', nil]
        it 'returns false' do
          expect(game.valid_promotion?(game.player2.pawn[5], game.player2, move)).to be(false)
        end
      end

      context 'when it is not promotable and the notation is invalid while the negate filter is on' do
        before { allow(game.player2).to receive(:random_destination).and_return([99, 18]) }
        it 'returns true' do
          move = ['', 'e4', 'x', '', '=R', nil]
          expect(game.valid_promotion?(game.player2.pawn[4], game.player2, move, negate: false)).to be(true)
        end
      end
    end


end

  describe '#invalid_promotion' do
    context 'when the second pawn of player one is at c7 attempts a promotion at d8' do
      before do
        game.board.layout[6][2].current_position = nil
        game.board.layout[6][2] = game.board.layout[1][1]
        game.board.layout[1][1] = nil
        game.board.layout[6][2].current_position = [6, 2]

        game.board.layout[0][6].current_position = nil
        game.board.layout[0][6] = nil
      end

      context 'when the move elements are legitimate and match a promotion' do
        it 'returns nil' do
          move = ['', '', '', 'd8', '=N', nil]
          expect(game.invalid_promotion(game.player1.pawn[1], move, game.player1)).to be_nil
        end
      end

      context 'when the move elements are legitimate but they do not match a promotion' do
        it 'returns nil' do
          move = ['N', '', '', 'h3', '', nil]
          expect(game.invalid_promotion(game.player1.knight[1], move, game.player1)).to be_nil
        end
      end

      context 'when the move elements are legitimate and match a promotion' do
        let(:move) { ['', '', '', 'd8', '', nil] }
        let(:action) { game.invalid_promotion(game.player1.pawn[1], move, game.player1) }
        it 'returns false and prints the error message' do
          msg = "\nThis should be a promotion move. Please try again.\n"
          expect{action}.to output(msg).to_stdout
          expect(action).to be(false)
        end
      end

      context 'when the move elements are legitimate but they do not match a promotion' do
        let(:move) { ['', '', '', 'h8', '=N', nil] }
        let(:action) { game.invalid_promotion(game.player1.pawn[7], move, game.player1) }
        it 'returns false and prints the error message' do
          msg = "\nThis move is not qualified for a promotion. Please try again.\n"
          expect{action}.to output(msg).to_stdout
          expect(action).to be(false)
        end
      end
    end

    context 'when the last pawn of player two is at h2   attempts a promotion at g1' do
      before do
        game.board.layout[6][6].current_position = nil
        game.board.layout[1][7] = game.board.layout[6][6]
        game.board.layout[6][6] = nil
        game.board.layout[1][7].current_position = [1, 7]

        game.board.layout[7][3].current_position = nil
        game.board.layout[7][3] = nil

      end

      context 'when the move elements are legitimate and match a promotion' do
        before { allow(game.player2).to receive(:random_destination).and_return([0, 6]) }
        it 'returns nil' do
          move = ['', '', '', 'g1', '=Q', nil]
          expect(game.invalid_promotion(game.player2.pawn[7], move, game.player2)).to be_nil
        end
      end

      context 'when the move elements are legitimate but they do not match a promotion' do
        before { allow(game.player2).to receive(:random_destination).and_return([4, 4]) }

        it 'returns nil' do
          move = ['', '', '', 'e5', '', nil]
          expect(game.invalid_promotion(game.player2.pawn[4], move, game.player2)).to be_nil
        end
      end
    end
  end

  describe '#validate_promotion' do
    let(:player1) { game.player1 }
    let(:human_pawn) { game.player1.pawn }
    let(:player2) { game.player2 }
    let(:npc_pawn) { game.player2.pawn}

    context 'when the fifth pawn of player one at f7 moves to e8 ' do
      before do
        game.board.layout[6][5].current_position = nil
        game.board.layout[6][5] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[6][5].current_position = [6, 5]

        game.board.layout[0][3].current_position = nil
        game.board.layout[0][3] = nil
      end

      context 'when the promotion is not valid' do
        let(:action) { game.validate_promotion(player1, [7, 4], PIECE_STATS, human_pawn[4], human_pawn[1]) }
        it 'prints the error message and returns false' do
          msg = "\nIt not a valid piece for promotion. Please try again.\n"
          expect{ action }.to output(msg).to_stdout
          expect(action).to be(false)
        end
      end

      context 'when the promotion is valid' do
        let(:queen) { game.player1.queen[0] }
        let(:action) { game.validate_promotion(player1, [7, 4], PIECE_STATS, human_pawn[4], queen) }

        it 'does not print the error message and returns true' do
          msg = "\nIt not a valid piece for promotion. Please try again.\n"
          expect{ action }.not_to output(msg).to_stdout
          expect(action).to be(true)
        end

        it 'changes the position of player one\'s queen to e5' do
          expect{ action }.to change{ queen.current_position }.from(nil).to([7, 4])
          expect(game.board.layout[7][4]).to be(queen)
        end

        it 'changes the position of player one\'s fifth pawn to nil' do
          expect{ action }.to change{ human_pawn[4].current_position }.from([6, 5]).to(nil)
          expect(game.board.layout[6][5]).to be_nil
        end

        it 'changes the position of player two\'s king to nil (captured)' do
          expect{ action }.to change{ game.player2.king[0].current_position }.from([7, 4]).to(nil)
        end
      end
    end

    context 'when the sixth pawn of player two at g2 moves to f1 ' do
      before do
        game.board.layout[1][6].current_position = nil
        game.board.layout[1][6] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[1][6].current_position = [1, 6]

        game.board.layout[7][5].current_position = nil
        game.board.layout[7][5] = nil

        allow(game.player2).to receive(:random_destination).and_return([0, 5])
      end

      context 'when the promotion is not valid' do
        let(:action) { game.validate_promotion(player2, [0, 5], PIECE_STATS, npc_pawn[5], npc_pawn[7]) }
        it 'does not print the error message and returns false' do
          msg = "\nIt not a valid piece for promotion. Please try again.\n"
          expect{ action }.not_to output(msg).to_stdout
          expect(action).to be(false)
        end
      end

      context 'when the promotion is valid' do
        let(:bishop) { game.player2.bishop[1] }
        let(:action) { game.validate_promotion(player2, [0, 5], PIECE_STATS, npc_pawn[5], bishop) }

        it 'returns true' do
          expect(action).to be(true)
        end

        it 'changes the position of player two\'s bishop to f1' do
          expect{ action }.to change{ bishop.current_position }.from(nil).to([0, 5])
          expect(game.board.layout[0][5]).to be(bishop)
        end

        it 'changes the position of player two\'s sixth pawn to nil' do
          expect{ action }.to change{ npc_pawn[5].current_position }.from([1, 6]).to(nil)
          expect(game.board.layout[1][6]).to be_nil
        end

        it 'changes the position of player one\'s bishop to nil (captured)' do
          expect{ action }.to change{ game.player1.bishop[1].current_position }.from([0, 5]).to(nil)
        end
      end
    end
  end

  describe '#invalid_moves' do
    context 'when the active piece is the king of the first player' do
      it 'returns nil' do
        expect(game.invalid_moves(game.player1, game.player1.king)).to be_nil
      end
    end

    context 'when the active pieces are all pawns of the first player' do
      let(:action) { game.invalid_moves(game.player1, game.player1.pawn) }

      it 'prints the error message and returns false' do
        msg = "\nThere are 8 pieces that can make the move. Please specify."
        expect{ action }.to output(include(msg)).to_stdout
        expect(action).to be(false)
      end
    end

    context 'when the active pieces empty for the first player' do
      let(:action) { game.invalid_moves(game.player1, []) }
      it 'prints the error message and returns false' do
        msg = "\nIt is not a valid move. Please try again.\n"
        expect{ action }.to output(include(msg)).to_stdout
        expect(action).to be(false)
      end
    end

    context 'when the active piece is the queen of the second player' do
      it 'returns nil' do
        expect(game.invalid_moves(game.player2, game.player2.queen)).to be_nil
      end
    end

    context 'when the active pieces are both knights of the second player' do
      let(:action) { game.invalid_moves(game.player2, game.player2.knight) }

      it 'does not print the error message and returns false' do
        msg = "\nThere are 2 pieces that can make the move. Please specify."
        expect{ action }.not_to output(include(msg)).to_stdout
        expect(action).to be(false)
      end
    end

    context 'when the active pieces empty for the second player' do
      let(:action) { game.invalid_moves(game.player2, []) }

      it 'does not print the error message and returns false' do
        msg = "\nIt is not a valid move. Please try again.\n"
        expect{ action }.not_to output(include(msg)).to_stdout
        expect(action).to be(false)
      end
    end
  end

  describe '#valid_castling' do
    let(:player1) { game.player1 }
    let(:human_king) { player1.king[0] }
    let(:human_rook) { player1.rook }

    context 'when player one executes king castling'
      context 'when the king castling is valid' do
        it 'returns true' do
          move_elements = ['', '', '', '', '', '0-0']
          expect(game.valid_castling?(move_elements, player1, human_king, human_rook[1])).to be(true)
        end
      end

      context 'when the notation is invalid' do
        it 'returns false' do
          move_elements = ['', '', '', '', '', nil]
          expect(game.valid_castling?(move_elements, player1, human_king, human_rook[0])).to be(false)
        end
      end

      context 'when notation is valid but the king is captured' do
        it 'returns true' do
          move_elements = ['', '', '', '', '', '0-0']
          expect(game.valid_castling?(move_elements, player1, nil, human_rook[0])).to be(true)
        end
      end

      context 'when notation is valid but the rook is captured' do
        it 'returns true' do
          human_rook[0].current_position = nil
          move_elements = ['', '', '', '', '', '0-0']
          expect(game.valid_castling?(move_elements, player1, human_king, human_rook[0])).to be(true)
        end
      end

      context 'when the notation is invalid but the negate filter is on' do
        it 'returns true' do
          move_elements = ['', '', '', '', '', nil]
          expect(game.valid_castling?(move_elements, player1, human_king, human_rook[0], negate: false)).to be(true)
        end
      end
    end

    context 'when the second player (computer) is executing a queen castling' do
      let(:player2) { game.player2 }
      let(:npc_king) { player2.king[0] }
      let(:npc_rook) { player2.rook }

      before do
        0.upto(7) do |idx|
          unless [4, 7].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        npc_king.castling_type = 'king_castling'
      end

      context 'when the notation is invalid but the castling condition is met' do
        it 'returns true' do
          move_elements = ['', '', '', '', '', nil]
          expect(game.valid_castling?(move_elements, player2, npc_king, npc_rook[1])).to be(true)
        end
      end

      context 'when the notation is valid but the castling condition is met' do
        it 'returns true' do
          move_elements = ['', '', '', '', '', 'O-O']
          expect(game.valid_castling?(move_elements, player2, npc_king, npc_rook[1])).to be(true)
        end
      end

      context 'when the notation is invalid and the castling condition is not met' do
        it 'returns false' do
          move_elements = ['', '', '', '', '', nil]
          expect(game.valid_castling?(move_elements, player2, npc_king, npc_rook[0])).to be(false)
        end
      end

      context 'when the negate filter is on' do
        it 'returns true' do
          move_elements = ['', '', '', '', '', nil]
          expect(game.valid_castling?(move_elements, player2, npc_king, npc_rook[0], negate: false)).to be(true)
        end
      end
  end

  describe '#active_piece_conditions' do
    context 'when the first pawn of player two is selected' do
      let(:pawn) { game.player2.pawn[0] }
      before { allow(game.player2).to receive(:random_destination).and_return([5, 0]) }

      it 'returns false for captured pieces' do
        pawn.current_position = nil
        expect(game.active_piece_conditions(pawn, game.player2, [5,0], nil, nil)).to be(false)
      end

      it 'returns true for valid moves without origin' do
        expect(game.active_piece_conditions(pawn, game.player1, [5,0], nil, nil)).to be(true)
      end

      it 'filters by origin when provided' do
        expect(game.active_piece_conditions(pawn, game.player1, [5, 0], [0], [1])).to be(true)
        expect(game.active_piece_conditions(pawn, game.player1, [5, 0], [6], [0])).to be(true)
        expect(game.active_piece_conditions(pawn, game.player1, [5, 0], [6, 0], [0, 1])).to be(true)
        expect(game.active_piece_conditions(pawn, game.player1, [5, 0], [2], [0])).to be(false)
      end
    end

    context 'when the rook on the queen side moves to e1' do
      let(:rook) { game.player1.rook[0] }
      before do
        0.upto(7) do |idx|
          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [0, 4, 7].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[1][idx] = nil
          end
        end

        game.board.layout[1][4] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[1][4].current_position = [1, 4]
      end

      it 'returns false for captured pieces' do
        rook.current_position = nil
        expect(game.active_piece_conditions(rook, game.player1, [0, 4], nil, nil)).to be(false)
      end

      it 'returns true for valid moves without origin' do
        expect(game.active_piece_conditions(rook, game.player1, [0 ,4], nil, nil)).to be(true)
      end

      it 'filters by origin when provided' do
        expect(game.active_piece_conditions(rook, game.player1, [0, 4], [0], [1])).to be(true)
        expect(game.active_piece_conditions(rook, game.player1, [0, 4], [0], [0])).to be(true)
        expect(game.active_piece_conditions(rook, game.player1, [0, 4], [0, 0], [0, 1])).to be(true)
        expect(game.active_piece_conditions(rook, game.player1, [0, 4], [2], [0])).to be(false)
      end

    end
  end

  describe '#active_pieces' do
    context 'when the destination is set at f5 and the active pieces are the pawns of player two' do
      before { allow(game.player2).to receive(:random_destination).and_return([4, 4]) }
      it 'returns the pawn at f5 of player two' do
        action = game.active_pieces(game.player2.pawn, game.player2, [4, 5])
        expect(action).to eq([game.player2.pawn[5]])
      end
    end

    context 'when the destination is set at f5 and the active pieces are the pawns of player one' do
      before do
        game.board.layout[5][3] = game.board.layout[1][3]
        game.board.layout[1][3] = nil
        game.board.layout[5][3].current_position = [5, 3]

        game.board.layout[5][5] = game.board.layout[1][5]
        game.board.layout[1][5] = nil
        game.board.layout[5][5].current_position = [5, 5]
      end

      it 'returns the pawn at f6 of player one' do
        action = game.active_pieces(game.player1.pawn, game.player1, [6, 4], [5], [1])
        expect(action).to eq([game.player1.pawn[5]])
      end
    end

    context 'when the destination is set at a5 and the active pieces are the rooks of player two' do
      before do
        game.board.layout[6][0].current_position = nil
        game.board.layout[6][0] = nil

        game.board.layout[6][7].current_position = nil
        game.board.layout[6][7] = nil

        game.board.layout[5][0] = game.board.layout[7][0]
        game.board.layout[7][0] = nil
        game.board.layout[5][0].current_position = [5, 0]

        game.board.layout[3][0] = game.board.layout[7][7]
        game.board.layout[7][7] = nil
        game.board.layout[3][0].current_position = [3, 0]

        allow(game.player2).to receive(:random_destination).and_return([4, 0])
      end

      it 'returns the rook at a6 of player two' do
        action = game.active_pieces(game.player2.rook, game.player2, [4, 0], [3], [0])
        expect(action).to eq([game.player2.rook[1]])
      end
    end

    context 'when the destination is set d5 and the active pieces are the knights of player one' do
      before do
        game.board.layout[2][2] = game.board.layout[0][1]
        game.board.layout[0][1] = nil
        game.board.layout[2][2].current_position = [2, 2]

        game.board.layout[3][5] = game.board.layout[0][6]
        game.board.layout[0][6] = nil
        game.board.layout[3][5].current_position = [3, 5]
      end

      it 'returns the knight at f4 of player one' do
        action = game.active_pieces(game.player1.knight, game.player2, [4, 3], [3, 5], [0, 1])
        expect(action).to eq([game.player1.knight[1]])
      end
    end

    context 'when the destination is set at d4 and the active pieces are the knights of player two' do
      before do
        game.board.layout[4][5] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[4][5].current_position = [4, 5]

        game.board.layout[5][2] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[5][2].current_position = [5, 2]

        allow(game.player2).to receive(:random_destination).and_return([3, 3])
      end

      it 'returns both knights of player two' do
        action = game.active_pieces(game.player2.knight, game.player2, [3, 3])
        expect(action).to eq(game.player2.knight)
      end
    end

    context 'when the destination is set at d3 and the active piece is the queen of player one' do
      it 'returns empty array' do
        action = game.active_pieces(game.player1.queen, game.player1, [2, 3])
        expect(action).to be_empty
      end
    end

    context 'when the active pieces are empty' do
      it 'returns empty array' do
        action = game.active_pieces([], game.player1, [7, 7])
        expect(action).to be_empty
      end
    end
  end

  describe '#warning' do
    context 'when the king of player one is under check and checkmate by player two' do
      before do
        0.upto(7) do |idx|
          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [4].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil
          end

          unless [6].include?(idx)
            game.board.layout[6][idx].current_position = nil
            game.board.layout[6][idx] = nil
          end

          unless [2, 4].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        game.board.layout[0][7] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[0][7].current_position = [0, 7]
        game.board.layout[0][7].checked_positions = [[0, 6], [1, 6], [1, 7]]

        game.board.layout[1][6] = game.board.layout[6][6]
        game.board.layout[6][6] = nil
        game.board.layout[1][6].current_position = [1, 6]

        game.board.layout[2][7] = game.board.layout[7][4]
        game.board.layout[7][4] = nil
        game.board.layout[2][7].current_position = [2, 7]

        game.board.layout[4][1] = game.board.layout[7][2]
        game.board.layout[7][2] = nil
        game.board.layout[4][1].current_position = [4, 1]
      end

      it 'warns player one about the check' do
        msg = "\nPlayer 1, you are being checked! Please make your move wisely.\n"
        expect{ game.warning(game.player1) }.to output(msg).to_stdout
      end
    end


    context 'when the king of player two is checked by the first knight of player one' do
      before do
        game.board.layout[5][3] = game.board.layout[0][1]
        game.board.layout[0][1] = nil
        game.board.layout[5][3].current_position = [5, 3]

        game.board.layout[6][2].current_position = nil
        game.board.layout[6][2] = nil

        game.board.layout[6][4].current_position = nil
        game.board.layout[6][4] = nil
      end

      it 'warns player two about the check' do
        msg = "\nPlayer 2, you are being checked! Please make your move wisely.\n"
        expect{ game.warning(game.player2) }.to output(msg).to_stdout
      end
    end

    context 'when the check or checkmate conditions are not met' do
      it 'does not print the warning and returns nil for player two' do
        action = game.warning(game.player2)
        msg = "\nPlayer 1, you are being checked! Please make your move wisely.\n"
        expect{action}.not_to output(msg).to_stdout
        expect(action).to be_nil
      end

      it 'does not print the warning and returns nil for player one' do
        action = game.warning(game.player1)
        msg = "\nPlayer 2, you are being checked! Please make your move wisely.\n"
        expect{action}.not_to output(msg).to_stdout
        expect(action).to be_nil
      end
    end


    context 'when there is no win condition' do
      it 'returns nil for player one and does not print the winner message' do
        action = game.warning(game.player1)
        expect(action).to be_nil
        msg = "\nPlayer 1, you are being checked! Please make your move wisely.\n"
        expect{action}.not_to output(include(msg)).to_stdout
      end

      it 'returns nil for player two and does not print the winner message' do
        action = game.warning(game.player1)
        expect(action).to be_nil
        msg = "\nPlayer 2 is the winner!"
        expect{action}.not_to output(include(msg)).to_stdout
      end
    end
  end

  describe '#winner?' do
    context 'when the king of player two is captured' do
      before { game.player2.king[0].current_position = nil }
      it 'prints the message stating player one is the winner' do
        msg = "\nPlayer 1 is the winner!"
        expect {game.winner?(game.player1) }.to output(include(msg)).to_stdout
      end

      it 'returns that player one is the winner while player two is not' do
        expect(game.winner?(game.player1)).to be(true)
        expect(game.winner?(game.player2)).to be_nil
      end
    end

    context 'when there is no legal move for the king of player one to escape from check' do
      before do
        0.upto(7) do |idx|
          game.board.layout[6][idx].current_position = nil
          game.board.layout[6][idx] = nil

          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [4].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil
          end

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        game.board.layout[0][0] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[0][0].current_position = [0, 0]
        game.board.layout[0][0].checked_positions = [[1, 0], [1, 1], [0, 1]]

        game.board.layout[2][0] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][0].current_position = [2, 0]

        game.board.layout[2][1] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[2][1].current_position = [2, 1]

        game.board.layout[2][2] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[2][2].current_position = [2, 2]
      end

      it 'prints the message stating player two is the winner' do
        msg = "\nPlayer 2 is the winner!"
        expect {game.winner?(game.player1) }.to output(include(msg)).to_stdout
      end

      it 'returns true for player one and false for player two' do
        expect(game.winner?(game.player1)).to be(true)
        expect(game.winner?(game.player2)).to be_nil
      end
    end

    context 'when there is no win condition' do
      it 'returns nil for player one and does not print the winner message' do
        expect(game.winner?(game.player1)).to be_nil
        msg = "\nPlayer 1 is the winner!"
        expect{game.winner?(game.player1)}.not_to output(include(msg)).to_stdout
      end

      it 'returns nil for player two and does not print the winner message' do
        expect(game.winner?(game.player2)).to be_nil
        msg = "\nPlayer 2 is the winner!"
        expect{game.winner?(game.player2)}.not_to output(include(msg)).to_stdout
      end
    end
  end

  describe '#win_condition' do
    context 'when the current position of the king of the second player is set as nil' do
      before { game.player2.king[0].current_position = nil }
      it 'returns false for player two and true for player one' do
        expect(game.win_condition(game.player2)).to be(false)
        expect(game.win_condition(game.player1)).to be(true)
      end
    end

    context 'when the current position of the king of the first player is set as nil' do
      before do
        0.upto(7) do |idx|
          game.board.layout[6][idx].current_position = nil
          game.board.layout[6][idx] = nil

          game.board.layout[1][idx].current_position = nil
          game.board.layout[1][idx] = nil

          unless [4].include?(idx)
            game.board.layout[0][idx].current_position = nil
            game.board.layout[0][idx] = nil
          end

          unless [1, 3, 4, 6].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        game.board.layout[0][0] = game.board.layout[0][4]
        game.board.layout[0][4] = nil
        game.board.layout[0][0].current_position = [0, 0]
        game.board.layout[0][0].checked_positions = [[1, 0], [1, 1], [0, 1]]

        game.board.layout[2][0] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[2][0].current_position = [2, 0]

        game.board.layout[2][1] = game.board.layout[7][1]
        game.board.layout[7][1] = nil
        game.board.layout[2][1].current_position = [2, 1]

        game.board.layout[2][2] = game.board.layout[7][6]
        game.board.layout[7][6] = nil
        game.board.layout[2][2].current_position = [2, 2]
      end

      it 'returns true for player one and false for player two' do
        expect(game.win_condition(game.player1)).to be(true)
        expect(game.win_condition(game.player2)).to be(false)
      end
    end

    context 'when there is no win condition' do
      it 'returns false for player two and true for player one' do
        expect(game.win_condition(game.player1)).to be(false)
        expect(game.win_condition(game.player2)).to be(false)
      end
    end
  end

  describe '#king_captured?' do
    context 'when the king of the second player is examined at the beginning' do
      it 'returns false' do
        expect(game.king_captured?(game.player1)).to be(false)
      end
    end

    context 'when the king of the first player is examined at the beginning' do
      it 'returns false' do
        expect(game.king_captured?(game.player2)).to be(false)
      end
    end

    context 'when the current position of the king of the first player is set as nil' do
      before { game.player1.king[0].current_position = nil }
      it 'returns true' do
        expect(game.king_captured?(game.player2)).to be(true)
      end
    end

    context 'when the current position of the king of the second player is set as nil' do
      before { game.player2.king[0].current_position = nil }
      it 'returns true' do
        expect(game.king_captured?(game.player1)).to be(true)
      end
    end
  end

end
