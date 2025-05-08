# frozen_string_literal: true

RSpec.describe Configurable do
  let(:game) { Game.new }
  let(:player1) { game.player1 }
  let(:player2) { game.player2 }

  before do
    Player.player_count = 0
    Board.board_count = 0
    allow_any_instance_of(Human).to receive(:make_choice).and_return("2\n")
    allow($stdout).to receive(:write)
  end

  describe '#process_notation' do
    context 'when the second player perform a legitimate queen side castling' do
      before do
        0.upto(7) do |idx|
          game.board.layout[6][idx].current_position = nil
          game.board.layout[6][idx] = nil

          unless [0, 4].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        player2.king[0].castling_type = 'queen_castling'
      end

      let(:move) { ['', '', '', '', '', 'O-O-O'] }
      let(:king) { player2.king[0] }
      let(:rook) { player2.rook[0] }
      let(:action) { game.process_notation(PIECE_STATS, move, player2, king, rook) }

      it 'returns true on castling condition and movement' do
        expect(game.castling?(king, rook, player2)).to be(true)
        expect(game.castling_movement(PIECE_STATS, player2, move)).to be(true)
        expect(game.valid_castling?(move, player2, king, rook)).to be(true)
      end

      it 'returns c8 and d8 for the king\'s and rook\'s new position' do
        action
        expect(king.current_position).to eq([7, 2])
        expect(rook.current_position).to eq([7, 3])
      end
    end

    context 'when the first player perform king side castling at the beginning' do
      let(:move) { ['', '', '', '', '', 'O-O'] }
      let(:king) { player1.king[0] }
      let(:rook) { player1.rook[1] }
      let(:action) { game.process_notation(PIECE_STATS, move, player1, king, rook) }

      it 'returns true on castling condition and movement' do
        expect(game.castling?(king, rook, player2)).to be(false)
        expect(game.castling_movement(PIECE_STATS, player2, move)).to be(false)
        expect(game.valid_castling?(move, player2, king, rook)).to be(true)
      end

      it 'returns false on the castling movement condition and prints error message' do
        expect(game.castling_movement(PIECE_STATS, player1, move)).to be(false)
        msg = "\nIt is not a valid move. Requirement(s) for castling is/are not satisfied.\n"
        expect { game.castling_movement(PIECE_STATS, player1, move) }.to output(msg).to_stdout
      end

      it 'does not change anything' do
        expect { action }.not_to(change { king.current_position })
        expect { action }.not_to(change { rook.current_position })
      end
    end

    context 'when the second player moves the queen from h4 to f2' do
      before do
        game.board.layout[4][4] = game.board.layout[6][4]
        game.board.layout[6][4] = nil
        game.board.layout[4][4].current_position = [6, 4]

        game.board.layout[3][7] = game.board.layout[7][3]
        game.board.layout[7][3] = nil
        game.board.layout[3][7].current_position = [3, 7]

        allow(player2).to receive(:random_destination).and_return([1, 5])
      end

      let(:move) { ['Q', '', 'x', 'f2', '', nil] }
      let(:queen) { player2.queen[0] }
      let(:king) { player2.king[0] }
      let(:rook) { player2.rook[0] }
      let(:action) { game.process_notation(PIECE_STATS, move, player2, king, rook) }

      it 'returns false on the castling condition' do
        expect(game.castling?(king, rook, player2)).to be(false)
        expect(game.non_castling_movement(PIECE_STATS, player2, move)).to be(true)
        expect(game.valid_castling?(move, player2, king, rook)).to be(false)
      end

      it 'change the location of the queen and indicates that the pawn at [1, 5] is captured' do
        expect { action }.to change { queen.current_position }.from([3, 7]).to([1, 5])
        expect(game.board.layout[3][7]).to be_nil
        expect(player1.pawn[5].current_position).to be_nil
      end
    end

    context 'when the second player moves the queen from h4 to f2' do
      let(:move) { ['B', '', '', 'c4', '', nil] }
      let(:bishop) { player1.bishop[1] }
      let(:king) { player1.king[0] }
      let(:rook) { player1.rook[1] }
      let(:action) { game.process_notation(PIECE_STATS, move, player1, king, rook) }

      it 'returns false on the castling condition' do
        expect(game.castling?(king, rook, player1)).to be(false)
        expect(game.non_castling_movement(PIECE_STATS, player1, move)).to be(false)
        expect(game.valid_castling?(move, player1, king, rook)).to be(false)
      end

      it 'returns as an invalid move and prints error message' do
        expect(game.invalid_moves(player1, [])).to be(false)
        msg = "\nIt is not a valid move. Please try again.\n"
        expect { game.invalid_moves(player1, []) }.to output(include(msg)).to_stdout
      end

      it 'does not change anything' do
        expect { action }.not_to(change { bishop.current_position })
        expect(game.board.layout[0][5]).to be(bishop)
        expect(game.board.layout[3][2]).to be_nil
      end
    end
  end

  describe '#non_castling_movement' do
    context 'when the pawn of the first player moves from e2 to e4' do
      let(:move_elements) { ['', '', '', 'e4', '', nil] }
      let(:action) { game.non_castling_movement(PIECE_STATS, player1, move_elements) }
      let(:pawn) { player1.pawn[4] }

      it 'moves pawn to e4' do
        expect(game.invalid_moves(player1, [pawn])).to be_nil
        expect { action }.to change { pawn.current_position }.from([1, 4]).to([3, 4])
        expect(game.board.layout[1][4]).to be_nil
        expect(game.board.layout[3][4]).to be(pawn)
      end
    end

    context 'when the knight of the second player moves from g8 to f6' do
      let(:action) { game.non_castling_movement(PIECE_STATS, player2) }
      let(:knight) { player2.knight[1] }

      before do
        allow(player2).to receive(:available_pieces).and_return([knight])
        allow(player2).to receive(:random_destination).and_return([5, 5])
      end

      it 'contains the message that prompts the second player to make move' do
        msg = "\nIt is now Player 2's turn to move.\n"
        expect { action }.to output(include(msg)).to_stdout
      end

      it 'moves knight to f6' do
        expect { action }.to change { knight.current_position }.from([7, 6]).to([5, 5])
        expect(game.board.layout[7][6]).to be_nil
        expect(game.board.layout[5][5]).to be(knight)
      end
    end

    context 'when the king of the first player moves from e1 to d2 at the beginning' do
      let(:action) { game.non_castling_movement(PIECE_STATS, player1, ['K', '', '', 'd2', '', '']) }
      let(:king) { player2.king[0] }

      it 'prints the error message' do
        msg = "\nIt is not a valid move. Please try again.\n"
        expect { action }.to output(include(msg)).to_stdout
      end

      it 'does not change anything' do
        expect { action }.not_to(change { king.current_position })
        expect(game.board.layout[1][3]).to be(player1.pawn[3])
        expect(game.board.layout[0][4]).to be(player1.king[0])
      end
    end

    context 'when there is an ambiguous move Re8' do
      let(:rook) { player2.rook }

      before do
        0.upto(7) do |idx|
          game.board.layout[6][idx].current_position = nil
          game.board.layout[6][idx] = nil

          unless [0, 4, 7].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        game.board.layout[6][4] = game.board.layout[7][4]
        game.board.layout[7][4] = nil
        game.board.layout[6][4].current_position = [6, 4]

        allow(player2).to receive(:available_pieces).and_return(rook)
        allow(player2).to receive(:random_destination).and_return([7, 4])
      end

      let(:action) { game.non_castling_movement(PIECE_STATS, player2, ['R', '', '', 'e8', '', '']) }

      it 'does not change anything' do
        expect(game.invalid_moves(player2, rook)).to be(false)
        expect { action }.not_to(change { rook[0].current_position })
        expect { action }.not_to(change { rook[1].current_position })
        expect(game.board.layout[7][0]).to be(player2.rook[0])
        expect(game.board.layout[7][7]).to be(player2.rook[1])
      end
    end
  end

  describe '#make_normal_moves' do
    context 'when the second player is a computer' do
      let(:action) { game.make_normal_moves([player2.pawn[0]], nil, PIECE_STATS, player2, [4, 0]) }
      before { allow(player1).to receive(:make_choice).and_return("2\n") }

      it 'contains the message that prompts the player to make moves' do
        msg = "\nIt is now Player 2's turn to move.\n"
        expect { action }.to output(include(msg)).to_stdout
      end
    end

    context 'when there are 2 knights that can make it to d2' do
      before do
        game.board.layout[2][5] = game.board.layout[0][6]
        game.board.layout[0][6] = nil
        game.board.layout[2][5].current_position = [2, 5]

        game.board.layout[1][3].current_position = nil
        game.board.layout[1][3] = nil
      end

      let(:move) { ['N', '', '', 'd2', '', ''] }
      let(:action) { game.make_normal_moves(player1.knight, move, PIECE_STATS, player1, [1, 3]) }

      it 'prints the error message and changes nothing' do
        msg = "\nThere are 2 pieces that can make the move. Please specify.\n"
        expect { action }.to output(include(msg)).to_stdout
        expect(player1.knight[0].current_position).to eq([0, 1])
        expect(player1.knight[1].current_position).to eq([2, 5])
        expect(game.board.layout[1][3]).to be_nil
      end

      it 'returns false on the invalid moves' do
        expect(game.invalid_moves(player1, player1.knight)).to be(false)
      end
    end

    context 'when the pawn of player two at g4 performs an en passant move to h3' do
      before do
        game.board.layout[3][6] = game.board.layout[6][6]
        game.board.layout[6][6] = nil
        game.board.layout[3][6].current_position = [3, 6]

        game.board.layout[3][7] = game.board.layout[1][7]
        game.board.layout[1][7] = nil
        game.board.layout[3][7].current_position = [3, 7]
        game.board.layout[3][7].double_step[1] = true
      end

      context 'when the notation is starting with an origin' do
        let(:move) { ['', '', 'g', 'h3', '', nil] }
        let(:action) { game.make_normal_moves([player2.pawn[6]], move, PIECE_STATS, player2, [2, 7]) }

        it 'does not print the error message' do
          msg = "\nThis is an en passant move. The notation should start with the file of the pawn performing the move.\n"
          expect { action }.not_to output(include(msg)).to_stdout
        end

        it 'changs the position of the pawn from g4 to h3' do
          expect{action}.to change{player2.pawn[6].current_position}.from([3, 6]).to([2, 7])
        end

        it 'captures the pawn at h4' do
          expect{action}.to change{player1.pawn[7].current_position}.from([3, 7]).to(be_nil)
          expect(game.board.layout[3][7]).to(be_nil)
        end
      end

      context 'when the rooks at a1 and h1 of player1 can both move to e1' do
        before do
          0.upto(7) do |idx|
            unless [0, 4, 7].include?(idx)
              game.board.layout[0][idx].current_position = nil
              game.board.layout[0][idx] = nil
            end
          end
          game.board.layout[2][4] = game.board.layout[1][4]
          game.board.layout[1][4] = nil
          game.board.layout[2][4] = [2, 4]

          game.board.layout[1][4] = game.board.layout[0][4]
          game.board.layout[0][4] = nil
          game.board.layout[1][4] = [1, 4]
        end

        context 'when the rook at h1 makes the move' do
          let(:move) { ['R', '', '7', 'e1', '', nil] }
          let(:action) { game.make_normal_moves([player1.rook[1]], move, PIECE_STATS, player1, [0, 4]) }

          it 'does not print the error message' do
            msg = "\nThere are 2 pieces that can make the move. Please specify."
            expect { action }.not_to output(include(msg)).to_stdout
          end

          it 'changs the position of the rook from h1 to e1' do
            expect{action}.to change{player1.rook[1].current_position}.from([0, 7]).to([0, 4])
            expect(game.board.layout[0][7]).to(be_nil)
          end
        end

        context 'when the rook at a1 makes the move' do
          let(:move) { ['R', '', '0', 'e1', '', nil] }
          let(:action) { game.make_normal_moves([player1.rook[0]], move, PIECE_STATS, player1, [0, 4]) }

          it 'does not print the error message' do
            msg = "\nThere are 2 pieces that can make the move. Please specify."
            expect { action }.not_to output(include(msg)).to_stdout
          end

          it 'changs the position of the rook from h1 to e1' do
            expect{action}.to change{player1.rook[0].current_position}.from([0, 0]).to([0, 4])
            expect(game.board.layout[0][0]).to(be_nil)
          end
        end

      end
    end

    context 'when the queen attempts to move to h5 at the beginning' do
      before { allow(player1).to receive(:make_choice).and_return("2\n") }
      let(:move) { ['Q', '', '', 'h5', '', ''] }
      let(:action) { game.make_normal_moves([], move, PIECE_STATS, player1, [4, 7]) }

      it 'prints the error message and changes nothing' do
        msg = "\nIt is not a valid move. Please try again.\n"
        expect { action }.to output(include(msg)).to_stdout
        expect(player1.queen[0].current_position).to eq([0, 3])
        expect(game.board.layout[4][7]).to be_nil
      end

      it 'returns falase on the invalid moves' do
        expect(game.invalid_moves(player1, [])).to be(false)
      end
    end

    context 'when the knight on the king side of the second player moves from g8 to h6' do
      before { allow(player1).to receive(:make_choice).and_return("2\n") }
      let(:move) { ['N', '', '', 'h6', '', ''] }
      let(:action) { game.make_normal_moves([player2.knight[1]], move, PIECE_STATS, player2, [5, 7]) }

      it 'returns h6 as the new location of the knight piece and the original location should now be nil' do
        action
        expect(player2.knight[1].current_position).to eq([5, 7])
        expect(game.board.layout[7][6]).to be_nil
      end
    end

    context 'when the pawn at f7 attempts to perform a promotion at g8' do
      before do
        game.board.layout[6][5].current_position = nil
        game.board.layout[6][5] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[6][5].current_position = [6, 5]

        allow(player1).to receive(:make_choice).and_return("1\n")
      end
      let(:move) { ['', '', '', 'g8', '=R', ''] }
      let(:action) { game.make_normal_moves([player1.pawn[4]], move, PIECE_STATS, player1, [7, 6]) }

      it 'returns 3 rooks for the first player and the third rook is at g8' do
        action
        expect(player1.rook.count).to eq(3)
        expect(player1.rook[2].current_position).to eq([7, 6])
      end

      it 'returns nil for the fourth pawn and the previous location of the pawn is now nil' do
        action
        expect(player1.pawn[4].current_position).to be_nil
        expect(game.board.layout[6][5]).to be_nil
      end
    end
  end

  describe '#define_promoted_piece' do
    context 'when the pawn at e2 attempts to perform a promotion at e8' do
      before { allow(player1).to receive(:make_choice).and_return("1\n") }
      let(:move) { ['', '', '', 'e8', '=Q', ''] }
      let(:action) { game.define_promoted_piece(player1.pawn[4], move, PIECE_STATS, player1, [7, 4]) }

      it 'prints an error message and does not change anything on the board' do
        msg = "\nThis move is not qualified for a promotion. Please try again.\n"
        expect { action }.to output(msg).to_stdout
        expect(player1.pawn[4].current_position).to eq([1, 4])
        expect(game.board.layout[7][4]).to be(player2.king[0])
      end
    end

    context 'when the pawn at f7 attempts to perform a promotion at g8' do
      before do
        game.board.layout[6][5].current_position = nil
        game.board.layout[6][5] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[6][5].current_position = [6, 5]

        allow(player1).to receive(:make_choice).and_return("1\n")
      end
      let(:move) { ['', '', '', 'g8', '', ''] }
      let(:action) { game.define_promoted_piece(player1.pawn[4], move, PIECE_STATS, player1, [7, 6]) }

      it 'prints an error message and does not change anything on the board' do
        msg = "\nThis should be a promotion move. Please try again.\n"
        expect { action }.to output(msg).to_stdout
        expect(player1.pawn[4].current_position).to eq([6, 5])
        expect(game.board.layout[7][6]).to be(player2.knight[1])
      end
    end

    context 'when the knight on the king side of the second player moves from g8 to h6' do
      before { allow(player1).to receive(:make_choice).and_return("1\n") }

      it 'returns h6 as the new location of the knight piece and the original location should now be nil' do
        move = ['N', '', '', 'h6', '', '']
        game.define_promoted_piece(player2.knight[1], move, PIECE_STATS, player2, [5, 7])
        expect(player2.knight[1].current_position).to eq([5, 7])
        expect(game.board.layout[7][6]).to be_nil
      end
    end

    context 'when the pawn at f7 attempts to perform a promotion at g8' do
      before do
        game.board.layout[6][5].current_position = nil
        game.board.layout[6][5] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[6][5].current_position = [6, 5]

        allow(player1).to receive(:make_choice).and_return("1\n")
      end
      let(:move) { ['', '', '', 'g8', '=R', ''] }
      let(:action) { game.define_promoted_piece(player1.pawn[4], move, PIECE_STATS, player1, [7, 6]) }

      it 'returns 3 rooks for the first player and the third rook is at g8' do
        action
        expect(player1.rook.count).to eq(3)
        expect(player1.rook[2].current_position).to eq([7, 6])
      end

      it 'returns nil for the fourth pawn and the previous location of the pawn is now nil' do
        action
        expect(player1.pawn[4].current_position).to be_nil
        expect(game.board.layout[6][5]).to be_nil
      end
    end
  end

  describe '#castling_movement' do
    context 'when the first player trys to perform king side castling at the beginning' do
      let(:action) { game.castling_movement(PIECE_STATS, player1, ['', '', '', '', '', 'O-O-O']) }

      before { allow(player1).to receive(:make_choice).and_return("1\n") }

      it 'prints the error message' do
        msg = "\nIt is not a valid move. Requirement(s) for castling is/are not satisfied.\n"
        expect { action }.to output(msg).to_stdout
      end

      it 'returns the same locations for the king and the rook' do
        expect(player1.king[0].current_position).to eq([0, 4])
        expect(player1.rook[1].current_position).to eq([0, 7])
      end

      it 'returns nil for the player notation' do
        expect(player1.notation).to all(be_nil)
      end

      it 'returns false' do
        expect(action).to be(false)
      end
    end

    context 'when the second player trys to perform a castling randomly' do
      before do
        0.upto(7) do |idx|
          game.board.layout[6][idx].current_position = nil
          game.board.layout[6][idx] = nil

          unless [0, 4, 7].include?(idx)
            game.board.layout[7][idx].current_position = nil
            game.board.layout[7][idx] = nil
          end
        end

        allow(player1).to receive(:make_choice).and_return("2\n")
      end

      let(:action) { game.castling_movement(PIECE_STATS, player2, nil) }

      it 'contains the message that prompts the second player to make move' do
        msg = "\nIt is now Player 2's turn to move.\n"
        expect { action }.to output(include(msg)).to_stdout
      end

      it 'returns the same locations for the king and the rook' do
        game.castling_movement(PIECE_STATS, player2, nil)
        expect([[7, 2], [7, 6]].include?(player2.king[0].current_position)).to be(true)
        expect([[7, 0], [7, 3]].include?(player2.rook[0].current_position)).to be(true)
        expect([[7, 5], [7, 7]].include?(player2.rook[1].current_position)).to be(true)
      end

      it 'returns nil for the player notation' do
        game.castling_movement(PIECE_STATS, player2, nil)
        expect(['O-O', 'O-O-O'].include?(player2.notation[-1])).to be(true)
      end

      it 'returns true' do
        expect(action).to be(true)
      end
    end
  end

  describe '#reset_pawn' do
    context 'when the pawns of the second player have been set to false continuous movement' do
      before do
        player2.pawn.each { |piece| piece.continuous_movement = false }
        game.reset_pawn(player2)
      end
      it 'returns all pawns of the second player to switch to true continuous movement' do
        expect(player2.pawn.all?(&:continuous_movement)).to be(true)
      end
    end

    context 'when the pawns of the second player have been set to false first move and continuous movement' do
      before do
        player2.pawn.each do |piece|
          piece.first_move = false
          piece.continuous_movement = false
        end
        game.reset_pawn(player2)
      end
      it 'returns all pawns of the second player to remain false continuous movement' do
        expect(player2.pawn.none?(&:continuous_movement)).to be(true)
      end
    end
  end

  describe '#change_state' do
    context 'when the fourth pawn at e5 is performing an en passant (f6)' do
      before do
        game.board.layout[4][4] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[4][4].current_position = [4, 4]

        game.board.layout[4][5] = game.board.layout[6][5]
        game.board.layout[6][5] = nil
        game.board.layout[4][5].current_position = [4, 5]
        game.board.layout[4][5].double_step[1] = true

        game.change_state(player1, [5, 5], PIECE_STATS, player1.pawn[4], nil)
      end

      it 'returns the notation exf6 e.p.' do
        expect(player1.notation).to eq([nil, 'e', 'x', 'f6 e.p.', nil])
      end

      it 'returns [5, 5] as the fourth pawn\'s current location' do
        expect(player1.pawn[4].current_position).to eq([5, 5])
      end

      it 'returns [[1, 4]] as the checked position of the player one\'s king' do
        expect(player1.king[0].checked_positions).to eq([[1, 4]])
      end

      it 'returns nil as the current position of the player two\'s fifth pawn (captured)' do
        expect(player2.pawn[5].current_position).to be(nil)
      end

      it 'updates the available destinations for player two and should not be nil' do
        expect(player2.available_destinations).not_to be(nil)
      end
    end

    context 'when the second knight at g8 is moving to h6' do
      before do
        game.change_state(player2, [5, 7], PIECE_STATS, player2.knight[1], nil)
      end

      it 'returns the notation Nh6' do
        expect(player2.notation).to eq(['N', nil, nil, 'h6', nil])
      end

      it 'returns [5, 7] as the second knight\'s current location' do
        expect(player2.knight[1].current_position).to eq([5, 7])
      end

      it 'returns [] as the checked position of the player two\'s king' do
        expect(player2.king[0].checked_positions).to be_empty
      end

      it 'returns nil for the previous location of the knight' do
        expect(game.board.layout[7][6]).to be(nil)
      end
    end
  end

  describe '#arrange_board' do
    context 'when the first player\'s knight on the king side moves to h3' do
      it 'moves the knight to h3, makes g1 empty, and does not change the first move' do
        game.arrange_board(player1.knight[1], [2, 7], nil)
        expect(game.board.layout[0][6]).to be_nil
        expect(player1.knight[1].current_position).to eq([2, 7])
        expect(player1.knight[1].first_move).to eq(true)
      end
    end

    context 'when the first player\'s knight on the king side moves to h3' do
      before do
        game.board.layout[6][5].current_position = nil
        game.board.layout[6][5] = game.board.layout[1][4]
        game.board.layout[1][4] = nil
        game.board.layout[6][5].current_position = [6, 5]

        game.board.layout[0][3].current_position = nil
        game.board.layout[0][3] = nil
      end

      it 'moves the knight to h3, makes g1 empty, and does not change the first move' do
        game.arrange_board(player1.pawn[4], [7, 4], player1.queen[0])
        expect(game.board.layout[7][4]).to be_a(Queen)
        expect(player1.queen[0].current_position).to eq([7, 4])
        expect(player1.queen[0].first_move).to eq(true)
      end
    end
  end

  describe '#available_destinations' do
    context 'when the game first starts' do
      it 'returns the available locations where the second player can move' do
        locations = [
          [2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [3, 0], [3, 1], [3, 2],
          [3, 3], [3, 4], [3, 5], [3, 6], [3, 7], [4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5],
          [4, 6], [4, 7], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [6, 0],
          [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [7, 0], [7, 1], [7, 2], [7, 3],
          [7, 4], [7, 5], [7, 6], [7, 7]
        ]
        expect((locations - game.available_destinations(player2)).empty?).to be(true)
      end
    end
  end

  describe '#reset_piece' do
    context 'when the sixth pawn of the first player is selected for reset' do
      it 'changes the first move from true to false' do
        target = player1.pawn[6]
        expect { game.reset_piece(target) }.to change(target, :first_move).from(true).to(false)
      end
    end

    context 'when the king piece of the second player is selected for reset' do
      it 'changes the first move from true to false' do
        target = player2.king[0]
        expect { game.reset_piece(target) }.to change(target, :first_move).from(true).to(false)
      end
    end

    context 'when the second rook of the second player (already) is selected' do
      it 'does not change the first move' do
        target = player2.rook[1]
        target.first_move = false
        expect(target.first_move).to be(false)
        expect { game.reset_piece(target) }.not_to change(target, :first_move)
      end
    end

    context 'when the queen of the first player is selected' do
      it 'does not change the first move' do
        target = player1.queen[0]
        expect(target.first_move).to be(true)
        expect { game.reset_piece(target) }.not_to change(target, :first_move)
      end
    end
  end
end
