# frozen_string_literal: true

require './lib/game'
require './lib/player'
require './lib/serializable'

RSpec.describe Game do
  subject(:game) { described_class.new }
  let(:player1) { game.player1 }
  let(:player2) { game.player2 }
  let(:board) { game.board }

  before do
    Player.player_count = 0
    Board.board_count = 0
    allow_any_instance_of(Human).to receive(:make_choice).and_return("2\n")

    allow($stdout).to receive(:write)
  end

  matcher :be_reset do
    match { |p| p.continuous_movement == p.first_move }
  end

  matcher :be_character do |char|
    match { |p| p.unicode == char }
  end

  describe '#initialize' do
    context 'when the game is created' do
      context 'when the first player is created along with the game' do
        it 'returns a human as the first player and total number of players as 1' do
          Player.player_count -= 1
          expect(player1).to be_a(Human)
          expect(Player.player_count).to eq(1)
        end
      end

      context 'when the first player selects human as the second player' do
        it 'returns a human as the second player and total number of players as 2' do
          allow_any_instance_of(Human).to receive(:make_choice).and_return("1\n")
          expect(game.opponent_choice).to eq(1)
          expect(player2).to be_a(Human)
          expect(Player.player_count).to eq(2)
        end
      end

      context 'when the first player enters wrong input twice and computer as the second player' do
        it 'puts the prompt message 4 times and returns a computer as the second player' do
          allow_any_instance_of(Human).to receive(:make_choice).and_return("fqe\n", "\n", "2\n")
          msg = "Whom would you like to play against? Enter \"1\" for human or \"2\" for computer?\n"
          expect { game.opponent_choice }.to output(msg * 4).to_stdout
          expect(player2).to be_a(Computer)
        end
      end

      context 'when the first player selects computer as the second player' do
        it 'returns a computer as the second player and total number of players as 2' do
          expect(game.opponent_choice).to eq(2)
          expect(player2).to be_a(Computer)
          expect(Player.player_count).to eq(2)
        end
      end

      context 'when the board is created along with the game' do
        it 'returns a board and total number of boards as 1' do
          expect(board).to be_a(Board)
          expect(Board.board_count).to eq(1)
        end
      end

      context 'when the method set_up_board is called' do
        it 'returns 64 cells in the board' do
          expect(board.layout.flatten.count).to eq(64)
        end

        it 'returns the pawn pieces for player 1 at rank 2' do
          result = board.layout[1].flatten
          expect(result).to all(be_a(Pawn))
          expect(result).to all(be_character('♙'))
        end

        it 'returns the rook pieces for player 1 at rank 1 and files a and h' do
          result = board.layout[0].flatten.values_at(0, 7)
          expect(result).to all(be_a(Rook))
          expect(result).to all(be_character('♖'))
        end

        it 'returns the knight pieces for player 1 at rank 1 and files b and f' do
          result = board.layout[0].flatten.values_at(1, 6)
          expect(result).to all(be_a(Knight))
          expect(result).to all(be_character('♘'))
        end

        it 'returns the bishop pieces for player 1 at rank 1 and files c and e' do
          result = board.layout[0].flatten.values_at(2, 5)
          expect(result).to all(be_a(Bishop))
          expect(result).to all(be_character('♗'))
        end

        it 'returns the queen piece for player 1 at rank 1 and file d' do
          result = board.layout[0][3]
          expect(result).to be_a(Queen)
          expect(result).to be_character('♕')
        end

        it 'returns the king piece for player 1 at rank 1 and file e' do
          result = board.layout[0][4]
          expect(result).to be_a(King)
          expect(result).to be_character('♔')
        end

        it 'returns nil for ranks 3 to 6' do
          expect(board.layout[2..5].flatten).to all(be_nil)
        end

        it 'returns the pawn pieces for player 2 at rank 6' do
          result = board.layout[6].flatten
          expect(result).to all(be_a(Pawn))
          expect(result).to all(be_character('♟'))
        end

        it 'returns the rook pieces for player 2 at rank 8 and files a and h' do
          result = board.layout[7].flatten.values_at(0, 7)
          expect(result).to all(be_a(Rook))
          expect(result).to all(be_character('♜'))
        end

        it 'returns the knight pieces for player 2 at rank 8 and files b and f' do
          result = board.layout[7].flatten.values_at(1, 6)
          expect(result).to all(be_a(Knight))
          expect(result).to all(be_character('♞'))
        end

        it 'returns the bishop pieces for player 2 at rank 8 and files c and e' do
          result = board.layout[7].flatten.values_at(2, 5)
          expect(result).to all(be_a(Bishop))
          expect(result).to all(be_character('♝'))
        end

        it 'returns the queen piece for player 2 at rank 8 and file d' do
          result = board.layout[7][3]
          expect(result).to be_a(Queen)
          expect(result).to be_character('♛')
        end

        it 'returns the king piece for player 2 at rank 8 and file e' do
          result = board.layout[7][4]
          expect(result).to be_a(King)
          expect(result).to be_character('♚')
        end
      end
    end
  end

  describe '#serialize_progress' do
    context 'when the game instance is established with some dummy variables' do

      before do
        game.instance_variable_set(:@player1, { king: [], queen: [] })  # Plain hash
        game.instance_variable_set(:@player2, { rook: [], pawn: [] })
        game.instance_variable_set(:@board, { layout: [] })
      end
      let(:data) { {:@board => {:layout=>[]}, :@player1 => {:king=>[], :queen=>[]}, :@player2 => {:pawn=>[], :rook=>[]}} }

      let(:progress) { game.serialize_progress }
      let(:save) { Marshal.load(progress) }

      it 'returns the instances variables of the game instance' do
        expect(game.organize_variables(game)).to eq(data)
      end

      it 'returns a serialized string' do
        expect(progress).to be_a(String)
        expect { Marshal.load(progress) }.not_to raise_error
      end

      it 'returns the content of the save after deserializing the progress' do
        expect(save).to be_a(Hash)
        expect(save).to eq(data)
      end

      it 'returns the values of the instance variables' do
        expect(save[:@player1]).to eq({:king => [], :queen => []})
        expect(save[:@player2]).to eq({:pawn => [], :rook => []})
        expect(save[:@board]).to eq({:layout => []})
      end
    end
  end

  describe '#save_progress' do
    context 'when some dummy data is stored' do
      before do
        game.instance_variable_set(:@player1, { king: [King], queen: [Queen] })  # Plain hash
        game.instance_variable_set(:@player2, { rook: [Rook, Rook], pawn: [Pawn, Pawn, Pawn, Pawn] })
        game.instance_variable_set(:@board, { layout: ['Nice'] })
      end
      let(:data) { {:@player1 => { king: [King], queen: [Queen] }, :@player2 => { rook: [Rook, Rook], pawn: [Pawn, Pawn, Pawn, Pawn] }, :@board => { layout: ['Nice'] }} }
      let(:test_file) { 'test_file_2.marshal' }

      it 'returns true the existence of the game file' do
        game.save_progress(test_file)
        expect(File.exist?(test_file)).to be(true)
      end

      it 'returns the data type of the game file' do
        progress = game.load_data(test_file)
        expect(progress).to be_a(Hash)
      end

      it 'returns the respectiive keys and values of the instance variable player1' do
        save = game.load_data(test_file)
        expect(save[:@player1].keys).to contain_exactly(*[:king, :queen])
        expect(save[:@player1][:king].count).to eq(1)
        expect(save[:@player1][:king]).to all(be(King))
        expect(save[:@player1][:queen].count).to eq(1)
        expect(save[:@player1][:queen]).to all(be(Queen))
      end

      it 'returns the respectiive keys and values of the instance variable player2' do
        save = game.load_data(test_file)
        expect(save[:@player2].keys).to contain_exactly(*[:rook, :pawn])
        expect(save[:@player2][:rook].count).to eq(2)
        expect(save[:@player2][:rook]).to all(be(Rook))
        expect(save[:@player2][:pawn].count).to eq(4)
        expect(save[:@player2][:pawn]).to all(be(Pawn))
      end

      it 'returns the respectiive keys and values of the instance variable board' do
        save = game.load_data(test_file)
        expect(save[:@board].keys).to eq([:layout])
        expect(save[:@board][:layout]).to eq(['Nice'])
      end
    end
  end

  describe '#load_progress' do
    let(:save) { game.load_progress('save_1.marshal') }
    context 'when the defaulted game file is loaded' do
      it 'changes the current position of the pawn of player one from e2 to e5' do
        expect{ save }.to change{ player1.pawn[4].current_position }.from([1, 4]).to([4, 4])
        expect(board.layout[1][4]).to be(nil)
        expect(board.layout[4][4]).to be_a(Pawn)
      end

      it 'changes the current position of the pawn of player two from d7 to d4' do
        expect{ save }.to change{ player2.pawn[3].current_position }.from([6, 3]).to([3, 3])
        expect(board.layout[6][3]).to be(nil)
        expect(board.layout[3][3]).to be_a(Pawn)
      end

      it 'does not change the locations of the other pieces of player one' do
        player1_pieces = player1.retrieve_pieces - [player1.pawn[4]]
        expect{ save }.not_to change{ player1_pieces.map(&:current_position) }
      end

      it 'does not change the locations of the other pieces of player two' do
        player2_pieces = player2.retrieve_pieces - [player2.pawn[3]]
        expect{ save }.not_to change{ player2_pieces.map(&:current_position) }
      end

      it 'does not change the board content' do
        spaces = Array(2..5).product(Array(0..7)) - [[4, 4], [3, 3]]
        spaces.each do |x, y|
          expect{ save }.not_to change{ board.layout[x][y] }
        end
      end

      it 'uses default filename when none specified' do
        allow(File).to receive(:read).with('save.marshal', {:mode=>'rb'}).and_call_original
        game.load_data
        expect(File).to have_received(:read).with('save.marshal', {:mode=>'rb'})
      end

    end
  end

  describe '#access_progress' do
    context 'when the access progress is defaulted to save the first player chooses not to save' do
      before do
        allow(player1).to receive(:make_choice).and_return("n\n")
      end

      it 'prompts the message asking the player if they want to save and returns "n" as the output' do
        msg = "\nWould you like to save your latest game progress? (y/n)\n"
        expect { game.access_progress }.to output(msg).to_stdout
        expect(game.access_progress).to eq("n\n")
        game.access_progress
      end
    end

    context 'when the access progress is defaulted to save the first player chooses to save' do
      before do
        allow(player1).to receive(:make_choice).and_return("y\n")
      end

      it 'prompts the message asking the player if they want to save and returns "y" as the output' do
        msg = "\nWould you like to save your latest game progress? (y/n)\n"
        expect { game.access_progress }.to output(msg).to_stdout
        expect(game.access_progress).to eq("y\n")
        game.access_progress
      end
    end

    context 'when the access progress is switched to load the first player chooses not to load' do
      before do
        allow(player1).to receive(:make_choice).and_return("n\n")
      end

      it 'prompts the message asking the player if they want to load and returns "n" as the output' do
        msg = "\nWould you like to load your latest game progress? (y/n)\n"
        expect { game.access_progress('load') }.to output(msg).to_stdout
        expect(game.access_progress('load')).to eq("n\n")
        game.access_progress
      end
    end

    context 'when the access progress is switched to load the first player chooses to load' do
      before do
        allow(player1).to receive(:make_choice).and_return("y\n")
      end

      it 'prompts the message asking the player if they want to load and returns "y" as the output' do
        msg = "\nWould you like to load your latest game progress? (y/n)\n"
        expect { game.access_progress('load') }.to output(msg).to_stdout
        expect(game.access_progress('load')).to eq("y\n")
        game.access_progress
      end
    end

    context 'when the first player enters something other y or n' do
      before do
        allow(player1).to receive(:make_choice).and_return("weroifjeoi\n", "y\n")
      end

      it 'prompts the message asking the player if they want to load and returns "y" as the output' do
        msg = "\nWould you like to load your latest game progress? (y/n)\n"
        expect { game.access_progress('load') }.to output(msg * 2).to_stdout
        expect(game.access_progress('load')).to eq("y\n")
        game.access_progress
      end
    end
  end

  describe '#players' do
    context 'when the method is called' do
      it 'returns a 2-element array of players 1 and 2' do
        expect(game.players.count).to eq(2)
        expect(game.players[0]).to be(player1)
        expect(game.players[1]).to be(player2)
      end
    end
  end

  describe '#register_opponent' do
    context 'when the first player selects 1' do
      before do
        allow(player1).to receive(:make_choice).and_return("1\n")
        Player.player_count = 1
      end
      it 'returns an instance of Human' do
        expect(game.register_opponent).to be_a(Human)
        expect(Player.player_count).to eq(2)
      end
    end

    context 'when the first player selects 2' do
      before do
        allow(player1).to receive(:make_choice).and_return("2\n")
        Player.player_count = 1
      end
      it 'returns an instance of Computer' do
        expect(game.register_opponent).to be_a(Computer)
        expect(Player.player_count).to eq(2)
      end
    end
  end

  describe '#opponent_choice' do
    context 'when the first player enters 1 (another human player is selected)' do
      it 'returns 1' do
        allow(player1).to receive(:make_choice).and_return("1\n")
        expect(game.opponent_choice).to eq(1)
      end
    end

    context 'when the first player enters 2 (a computer player is selected)' do
      it 'returns 1' do
        allow(player1).to receive(:make_choice).and_return("2\n")
        expect(game.opponent_choice).to eq(2)
      end
    end

    context 'when the first player enters invalid option' do
      it 'promots the player to enter a correct option' do
        allow(player1).to receive(:make_choice).and_return("sdfe\n", "1\n")
        msg = "Whom would you like to play against? Enter \"1\" for human or \"2\" for computer?\n"
        expect{game.opponent_choice}.to output(msg * 2).to_stdout
        expect(game.opponent_choice).to eq(1)
      end
    end
  end

  describe '#play' do
    context 'when the game starts fresh with loading progress' do
      before do
        allow(player1).to receive(:make_choice).and_return('n')

      end

      context 'when player one makes the first move as Nf3' do
        it 'prompts player one to enter their move' do
          msg = "\nPlayer 1, please enter your move:"
          expect{game.prompt_notation(1, player1)}.to output(include(msg)).to_stdout
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play
        end

        it 'returns no on loading game data' do
          expect(game.access_progress('load')).to eq('n')
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play
        end

        it 'does not print the warning about winner' do
          expect(game.warning(player1)).to be_nil
          msg = "\nPlayer 1, you are being checked! Please make your move wisely.\n"
          expect{ game.warning(player1) }.not_to output(msg).to_stdout
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play

        end

        it 'does not indicate a winner' do
          expect(game.winner?(player1)).to be_nil
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play
        end

        it 'changes the position of player one\'s knight from g1 to f3' do
          allow(game).to receive(:prompt_notation).and_return(['N', '', '', 'f3', '', nil])
          expect{ game.parse_notation(player1) }.to change{ player1.knight[1].current_position }.from([0, 6]).to([2, 5])
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play
        end

        it 'prints the move made by player one' do
          allow(game).to receive(:prompt_notation).and_return(['N', '', '', 'f3', '', nil])
          expect{ game.parse_notation(player1) }.to output("\nPlayer 1 just made this move => Nf3\n\n").to_stdout
          expect(game.winner?(player1)).to be_nil
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play
        end

        it 'does not prompt for player to save game' do
          expect(game).not_to receive(:access_progress).with('save')
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play
        end
      end

      context 'when player two makes the first move as b5' do
        before do
          allow(game).to receive(:access_progress).with('load').and_return('n')
          allow(game).to receive(:prompt_notation).and_return(['N', '', '', 'f3', '', nil])
          allow(player2).to receive(:random_destination).and_return([4, 1])
          allow(game).to receive(:win_condition).and_return(false)
        end

        it 'returns no on loading game data' do
          expect(game.access_progress('load')).to eq('n')
          expect(game).not_to receive(:load_progress).with('save_1.marshal')
          allow(game).to receive(:win_condition).with(player2).and_return(true)
          game.play
        end

        it 'returns a computer for player two' do
          expect(player2).to be_a(Computer)
        end

        it 'does not print the warning about winner' do
          expect(game.warning(player2)).to be_nil
          msg = "\nPlayer 2, you are being checked! Please make your move wisely.\n"
          expect{ game.warning(player2) }.not_to output(msg).to_stdout
          allow(game).to receive(:win_condition).with(player2).and_return(true)
          game.play
        end

        it 'does not indicate a winner' do
          expect(game.winner?(player2)).to be_nil
          allow(game).to receive(:win_condition).with(player2).and_return(true)
          game.play
        end

        it 'changes the position of player\'s two pawn from b7 to b5' do
          expect{ game.parse_notation(player2) }.to change{ player2.pawn[1].current_position }.from([6, 1]).to([4, 1])
          allow(game).to receive(:win_condition).with(player2).and_return(true)
          game.play
        end

        it 'prints the move made by player one' do
          msg = "Player 2 just made this move => b5"
          expect{ game.parse_notation(player2) }.to output(include(msg)).to_stdout
          expect(game.winner?(player2)).to be_nil
          allow(game).to receive(:win_condition).with(player2).and_return(true)
          game.play
        end
      end
    end

    context 'when the game starts with saved progress' do
      before do
        allow(player1).to receive(:make_choice).and_return('y')
        game.load_progress('save_2.marshal')
        allow(game).to receive(:win_condition).with(player1).and_return(true)

      end

      context 'when player one makes the next move as g8=Q' do
        it 'returns yes on loading game data' do
          expect(game.access_progress('load')).to eq('y')
          expect(game).to receive(:load_progress).with('save_2.marshal')
          game.play
        end

        it 'returns the new position of player one\'s chesses after loading game data' do
          expect(player1.pawn[4].current_position).to eq([6, 5])
        end

        it 'returns the new position of player two\'s chesses after loading game data' do
          expect(player2.pawn[1].current_position).to eq([4, 1])
          expect(player2.pawn[3].current_position).to eq([3, 3])
          expect(player2.pawn[5].current_position).to be_nil
          expect(player2.queen[0].current_position).to eq([5, 3])
        end

        it 'prints the warning message' do
          msg = "\nPlayer 2, you are being checked! Please make your move wisely.\n"
          expect{ game.warning(player2) }.to output(msg).to_stdout
          game.play
        end

        context 'when the pawn at f7 is promoted to e8 as a queen' do
          let(:action) { game.process_notation(PIECE_STATS, ['', '', '', 'e8', '=Q', nil], player1, nil, nil) }

          it 'returns the pawn being promoted no longer exists' do
            expect{ action }.to change{ player1.pawn[4].current_position }.from([6, 5]).to(nil)
            game.play
          end

          it 'returns the creation of a new queen and it\'s position after the promotion' do
            expect{ action }.to change{ player1.queen.count }.from(1).to(2)
            expect(player1.queen[1].current_position).to eq([7, 4])
            game.play
          end

          it 'returns the capture of the king' do
            expect{ action }.to change{ player2.king[0].current_position }.from([7, 4]).to(nil)
            expect(game.king_captured?(player1)).to be(true)
            game.play
          end

          it 'returns the winner as player one' do
            expect(game.winner?(player1)).to be(true)
            expect(game.win_condition(player1)).to be(true)
            allow(game).to receive(:king_captured?).with(player1).and_return(true)
            msg = "\nPlayer 1 is the winner!"
            expect{ game.winner?(player1) }.to output(include(msg)).to_stdout
            game.play
          end

          it 'prints the move made by player one' do
            allow(game).to receive(:prompt_notation).and_return(['', '', '', 'e8', '=Q', nil])
            msg = "\nPlayer 1 just made this move => xe8=Q\n\n"
            expect{ game.parse_notation(player1) }.to output(msg).to_stdout
            game.play
          end

          it 'does not prompt for player to save game' do
            expect(game).not_to receive(:access_progress).with('save')
            game.play
          end
        end
      end
    end

    context 'when the game starts with pre-loaded progress' do
      before do
        allow_any_instance_of(Human).to receive(:make_choice).and_return("1\n")
        allow(player1).to receive(:make_choice).and_return('y')
        game.load_progress('save_3.marshal')
        allow(game).to receive(:win_condition).with(player1).and_return(true)
      end

      context 'when the game save is loaded' do
        it 'returns yes on loading game data' do
          expect(game.access_progress('load')).to eq('y')
          game.play
        end

        it 'returns player two as a human' do
          expect(player2).to be_a(Human)
          game.play
        end

        it 'returns the new positions for player one\'s pieces' do
          expect(player1.pawn[2].current_position).to eq([3, 2])
          expect(player1.pawn[4].current_position).to eq([3, 4])
          expect(player1.pawn[5].current_position).to be_nil
        end

        it 'prints the warning message' do
          msg = "\nPlayer 1, you are being checked! Please make your move wisely.\n"
          expect{ game.warning(player1) }.to output(msg).to_stdout
          game.play
        end

        context 'when the bishop at d1 attempts to capture the pawn at f4' do
          before { allow(game).to receive(:win_condition).with(player1).and_return(false) }
          let(:action) { game.process_notation(PIECE_STATS, ['B', '', 'x', 'f4', '', nil], player1, nil, nil) }

          it 'does not change the position of the bishop' do
            expect{ action }.not_to change{ player1.bishop[0].current_position }
            expect(player1.bishop[0].current_position).to eq([0, 2])
            allow(game).to receive(:win_condition).with(player1).and_return(true)
            game.play
          end

          it 'does not capture the pawn' do
            expect{ action }.not_to change{ player2.pawn[4].current_position }
            expect(player2.pawn[4].current_position).not_to be_nil
            allow(game).to receive(:win_condition).with(player1).and_return(true)
            game.play
          end

          it 'prints the message to indicate an invalid move' do
            msg = "\nIt is not a valid move. Please try again.\n"
            expect{ action }.to output(msg).to_stdout
            allow(game).to receive(:win_condition).with(player1).and_return(true)
            game.play
          end

          it 'does not print the notation after movement' do
            msg = "\nPlayer 1 just made this move => Bxf4\n\n"
            expect{ game.reveal_move(2, player1) }.not_to output(msg).to_stdout
            allow(game).to receive(:win_condition).with(player1).and_return(true)
            game.play
          end

          it 'returns winner as nil' do
            expect(game.winner?(player1)).to be_nil
            allow(game).to receive(:win_condition).with(player1).and_return(true)
            game.play
          end

          it 'returns win condition as false' do
            expect(game.win_condition(player1)).to be(false)
            allow(game).to receive(:win_condition).with(player1).and_return(true)
            game.play
          end

          it 'does not trigger the save progress process' do
            expect(game).not_to receive(:save_progress).with(player1)
            allow(game).to receive(:win_condition).with(player1).and_return(true)
            game.play
          end
        end

        context 'when player one makes a valid move to c5' do
          before do
            allow(game).to receive(:prompt_notation).with(1, player1).and_return(['', '', '', 'c5', '', nil])
            allow(game).to receive(:win_condition).with(player2).and_return(false)
          end

          it 'returns the new positions for player two\'s pieces' do
            expect(player2.pawn[4].current_position).to eq([3, 5])
            expect(player2.queen[0].current_position).to eq([3, 7])
            allow(game).to receive(:win_condition).with(player2).and_return(true)
          end

          it 'does not print the warning message' do
            msg = "\nPlayer 2, you are being checked! Please make your move wisely.\n"
            expect{ game.warning(player2) }.not_to output(msg).to_stdout
            allow(game).to receive(:win_condition).with(player2).and_return(true)
            game.play
          end

          context 'when player two moves the queen from h4 to e1' do
            let(:action) { game.process_notation(PIECE_STATS, ['Q', '', 'x', 'e1', '', nil], player2, nil, nil) }

            it 'returns the new position of the queen' do
              expect{ action }.to change{ player2.queen[0].current_position }.from([3, 7]).to([0, 4])
              allow(game).to receive(:win_condition).with(player2).and_return(true)
              game.play
            end

            it 'returns the king of player one being captured' do
              expect{ action }.to change{ player1.king[0].current_position }.from([0, 4]).to(nil)
              expect(game.king_captured?(player2)).to be(true)
            end

            it 'prints the notation after movement' do
              action
              msg = "\nPlayer 2 just made this move => Qxe1\n\n"
              expect{ game.reveal_move(2, player2) }.to output(msg).to_stdout
              allow(game).to receive(:win_condition).with(player2).and_return(true)
              game.play
            end

            it 'returns winner as nil' do
              action
              allow(game).to receive(:win_condition).with(player2).and_return(true)
              expect(game.winner?(player2)).to be(true)
              expect{ game.winner?(player2) }.to output(include("\nPlayer 2 is the winner!")).to_stdout
              game.play
            end

            it 'does not trigger the access progress method' do
              allow(game).to receive(:win_condition).with(player2).and_return(true)
              expect(game).not_to receive(:access_progress).with('save')
              game.play
            end
          end
        end
      end
    end

    context 'when the game starts with pre-loaded progress' do
      before do
        allow(player1).to receive(:make_choice).and_return('y')
        game.load_progress('save_2.marshal')
        allow(game).to receive(:win_condition).with(player1).and_return(false)
      end

      context 'when the game save is loaded' do
        it 'returns yes on loading game data' do
          expect(game.access_progress('load')).to eq('y')
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play
        end

        it 'returns player two as a human' do
          expect(player2).to be_a(Computer)
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play
        end
      end

      context 'when both players make several moves' do
        let(:action_1) { game.process_notation(PIECE_STATS, ['', '', 'x', 'g8', '=Q', nil], player1, nil, nil) }

        before do
          action_1
          board.layout[5][4] = board.layout[5][3]
          board.layout[5][3] = nil
          board.layout[5][4].current_position = [5, 4]
          player2.notation = ['Q', nil, nil, 'e6', nil]
        end

        it 'returns the new positions of the moved pieces of player one' do
          expect(player1.pawn[4].current_position).to be_nil
          expect(game.player1.queen[1].current_position).to eq([7, 6])
          allow(game).to receive(:win_condition).with(player1).and_return(true)
          game.play
        end

        it 'returns the new positions of the moved pieces of player two' do
          expect(player2.queen[0].current_position).to eq([5, 4])
          allow(game).to receive(:win_condition).and_return(true)
          game.play
        end

        it 'prints the warning message to player one' do
          msg = "\nPlayer 1, you are being checked! Please make your move wisely.\n"
          expect{ game.warning(player1) }.to output(msg).to_stdout
          allow(game).to receive(:win_condition).and_return(true)
          game.play
        end
      end
    end
  end

  describe '#set_up_board' do
    let(:action) { game.set_up_board }
    let(:layout) { board.layout }

    def expect_changes(piece, *coordinates)
      coordinates.each do |x, y|
        expect { action }.to change { layout[x][y] }.from(nil).to(piece)
      end
    end

    def expect_unchanged(*coordinates)
      coordinates.each do |(x, y)|
        expect { action }.not_to change { layout[x][y] }
      end
    end

    context 'when the board is clear and set up' do
      before do
        layout.map(&:clear)
      end

      it 'returns rook for a1 and h1' do
        expect{ action }.to change { [layout[0][0], layout[0][7]] }.from([nil, nil]).to(all(be_a(Rook)))
        expect([layout[0][0].unicode, layout[0][7].unicode]).to all(eq('♖'))
      end

      it 'returns knight for b1 and g1' do
        expect{ action }.to change { [layout[0][1], layout[0][6]] }.from([nil, nil]).to(all(be_a(Knight)))
        expect([layout[0][1].unicode, layout[0][6].unicode]).to all(eq('♘'))
      end

      it 'returns bishop for c1 and f1' do
        expect{ action }.to change { [layout[0][2], layout[0][5]] }.from([nil, nil]).to(all(be_a(Bishop)))
        expect([layout[0][2].unicode, layout[0][5].unicode]).to all(eq('♗'))
      end

      it 'returns queen for d1' do
        expect{ action }.to change { layout[0][3] }.from(nil).to(be_a(Queen))
        expect(layout[0][3].unicode).to eq('♕')
      end

      it 'returns king for e1' do
        expect{ action }.to change { layout[0][4] }.from(nil).to(be_a(King))
        expect(layout[0][4].unicode).to eq('♔')
      end

      it 'does not change the content from a3 to h6' do
        locations = Array(2..5).product(Array(0..7))
        expect_unchanged(*locations)
      end

      it 'returns rook for a8 and h8' do
        expect{ action }.to change { [layout[7][0], layout[7][7]] }.from([nil, nil]).to(all(be_a(Rook)))
        expect([layout[7][0].unicode, layout[7][7].unicode]).to all(eq('♜'))
      end

      it 'returns knight for b8 and g8' do
        expect{ action }.to change { [layout[7][1], layout[7][6]] }.from([nil, nil]).to(all(be_a(Knight)))
        expect([layout[7][1].unicode, layout[7][6].unicode]).to all(eq('♞'))
      end

      it 'returns bishop for c8 and f8' do
        expect{ action }.to change { [layout[7][2], layout[7][5]] }.from([nil, nil]).to(all(be_a(Bishop)))
        expect([layout[7][2].unicode, layout[7][5].unicode]).to all(eq('♝'))
      end

      it 'returns queen for d8' do
        expect{ action }.to change { layout[7][3] }.from(nil).to(be_a(Queen))
        expect(layout[7][3].unicode).to eq('♛')
      end

      it 'returns king for e8' do
        expect{ action }.to change { layout[7][4] }.from(nil).to(be_a(King))
        expect(layout[7][4].unicode).to eq('♚')
      end
    end
  end

  describe '#player_turn' do
    context 'when player 1 is selected' do
      it 'returns the output 0' do
        expect(game.player_turn(player1)).to eq(0)
      end
    end

    context 'when player 2 is selected' do
      it 'returns the output 1' do
        expect(game.player_turn(player2)).to eq(1)
      end
    end
  end

  describe '#parse_notation' do
    context 'when player one enters e4' do
      before { allow(player1).to receive(:make_choice).and_return('e4') }
      let(:action) { game.parse_notation(player1) }
      let(:notation) { ["", "", "", "e4", "", nil] }

      it 'returns the player number as 0 (i.e., player one)' do
        expect(game.player_turn(player1)).to eq(0)
      end

      it 'returns the parsed notation as ["", "", "", "e4", "", nil]' do
        expect(game.prompt_notation(1, player1)).to eq(notation)
      end

      it 'triggers the reset pawn method' do
        expect(game).to receive(:reset_pawn).with(player1)
        action
      end

      it 'does not trigger the invalid notation method' do
        expect(game).not_to receive(:invalid_notation).with(notation, player1)
      end

      it 'returns the values for the parameters within process notation method' do
        expect(game).to receive(:process_notation) do |piece_stats, move_elements, player, king, rook|
          expect(player).to eq(player1)
          expect(move_elements).to eq(notation)
          expect(king).to be_nil
          expect(rook).to be_nil
        end
        action
      end

      it 'changes the pawn position from e2 to e4' do
        expect{ action }.to change{ player1.pawn[4].current_position }.from([1, 4]).to([3, 4])
      end

      it 'does not change the position of the other pieces' do
        other_locations = player1.piece_locations.delete(player1.pawn[4].current_position)
        expect{ action }.not_to change{ other_locations }
      end

      it 'prints the message in which player one makes a move' do
        msg = "\nPlayer 1 just made this move => e4\n\n"
        expect{game.parse_notation(player1)}.to output(include(msg)).to_stdout
      end
    end

    context 'when player two enters e4' do
      before do
        0.upto(7) do |idx|
          unless [4, 7].include?(idx)
            board.layout[7][idx].current_position = nil
            board.layout[7][idx] = nil
          end
        end
      end

      let(:action) { game.parse_notation(player2) }

      it 'returns the player number as 1 (i.e., player two)' do
        expect(game.player_turn(player2)).to eq(1)
      end

      it 'returns the king at e8, the rook at h8 and kingside castling' do
        expect(player2.valid_castling[0]).to be(player2.king[0])
        expect(player2.valid_castling[1]).to be(player2.rook[1])
        expect(player2.valid_castling[2]).to eq('O-O')
      end

      it 'triggers the reset pawn method' do
        expect(game).to receive(:reset_pawn).with(player2)
        action
      end

      it 'does not trigger the invalid notation method' do
        expect(game).not_to receive(:invalid_notation).with(nil, player2)
      end

      it 'returns the values for the parameters within process notation method' do
        expect(game).to receive(:process_notation) do |piece_stats, move_elements, player, king, rook|
          expect(player).to eq(player2)
          expect(move_elements).to eq(nil)
          expect(king).to be(player2.king[0])
          expect(rook).to be(player2.rook[1])
        end
        action
      end

      it 'changes the king\'s position from e8 to g8' do
        expect{ action }.to change{ player2.king[0].current_position }.from([7, 4]).to([7, 6])
      end

      it 'changes the rook\'s position from h8 to f8' do
        expect{ action }.to change{ player2.rook[1].current_position }.from([7, 7]).to([7, 5])
      end

      it 'does not change the position of the other pieces' do
        other_locations = player2.piece_locations.delete(player2.king[0].current_position)
        other_locations = player2.piece_locations.delete(player2.rook[1].current_position)
        expect{ action }.not_to change{ other_locations }
      end

      it 'prints the message in which player two makes a move' do
        msg = "\nPlayer 2 just made this move => O-O\n\n"
        expect{game.parse_notation(player2)}.to output(include(msg)).to_stdout
      end
    end

    context 'when the pawn of player one at f5 makes an en passant move to g6' do
      before do
        board.layout[4][5] = board.layout[1][5]
        board.layout[1][5] = nil
        board.layout[4][5].current_position = [4, 5]

        board.layout[4][6] = board.layout[6][6]
        board.layout[6][6] = nil
        board.layout[4][6].current_position = [4, 6]
        board.layout[4][6].double_step[1] = true

        allow(player1).to receive(:make_choice).and_return('fg6')
      end

      let(:action) { game.parse_notation(player1) }
      let(:notation) { ["", "f", "", "g6", "", nil] }


      it 'returns the player number as 0 (i.e., player one)' do
        expect(game.player_turn(player1)).to eq(0)
      end

      it 'returns the parsed notation as ["", "f", "", "g6", "", nil]' do
        expect(game.prompt_notation(1, player1)).to eq(notation)
      end

      it 'triggers the reset pawn method' do
        expect(game).to receive(:reset_pawn).with(player1)
        action
      end

      it 'does not trigger the invalid notation method' do
        expect(game).not_to receive(:invalid_notation).with(notation, player1)
      end

      it 'returns the values for the parameters within process notation method' do
        expect(game).to receive(:process_notation) do |piece_stats, move_elements, player, king, rook|
          expect(player).to eq(player1)
          expect(move_elements).to eq(notation)
          expect(king).to be_nil
          expect(rook).to be_nil
        end
        action
      end

      it 'changes the pawn position from f5 to g6' do
        expect{ action }.to change{ player1.pawn[5].current_position }.from([4, 5]).to([5, 6])
      end

      it 'captures the opponent pawn' do
        expect{ action }.to change{ player2.pawn[6].current_position }.from([4, 6]).to(nil)
      end

      it 'does not change the position of the other pieces' do
        other_locations = player1.piece_locations.delete(player1.pawn[5].current_position)
        expect{ action }.not_to change{ other_locations }
      end

      it 'does not change the position of the other opponent pieces' do
        other_locations = player2.piece_locations.delete(player2.pawn[6].current_position)
        expect{ action }.not_to change{ other_locations }
      end

      it 'prints the message in which player one makes a move' do
        msg = "\nPlayer 1 just made this move => fxg6 e.p.\n\n"
        expect{game.parse_notation(player1)}.to output(include(msg)).to_stdout
      end
    end

    context 'when the pawn of player two at f2 makes promotion to g1' do
      before do
        board.layout[1][5].current_position = nil
        board.layout[1][5] = nil

        board.layout[1][5] = board.layout[6][5]
        board.layout[6][5] = nil
        board.layout[1][5].current_position = [1, 5]

        board.layout[0][6].current_position = nil
        board.layout[0][6] = nil

        board.layout[7][3].current_position = nil
        board.layout[7][3] = nil

        allow(player2).to receive(:valid_castling).and_return(nil)
        allow(game).to receive(:process_notation).and_return(true) # Make sure loop exits
        allow(player2).to receive(:random_destination).and_return([0, 6])
      end

      let(:action) { game.parse_notation(player2) }
      let(:promotion) { game.validate_promotion(player2, [0, 6], PIECE_STATS, player2.pawn[5], player2.queen[0]) }


      it 'returns the player number as 1 (i.e., player two)' do
        expect(game.player_turn(player2)).to eq(1)
      end

      it 'does not trigger the prompt notation method' do
        expect(game).not_to receive(:prompt_notation).with(1, player2)
      end

      it 'returns nil on valid castling' do
        expect(player2.valid_castling).to be_nil
      end

      it 'triggers the reset pawn method' do
        expect(game).to receive(:reset_pawn).with(player2)
        action
      end

      it 'does not trigger the invalid notation method' do
        expect(game).not_to receive(:invalid_notation).with(nil, player2)
      end

      it 'returns the values for the parameters within process notation method' do
        expect(game).to receive(:process_notation) do |piece_stats, move_elements, player, king, rook|
          expect(player).to eq(player2)
          expect(move_elements).to eq(nil)
          expect(king).to be_nil
          expect(rook).to be_nil
        end
        action
      end

      it 'changes the pawn\'s position from f2 to nil' do
        expect{ promotion }.to change{ player2.pawn[5].current_position }.from([1, 5]).to(be_nil)
      end

      it 'changes the queen\'s position from nil to g1' do
        expect{ promotion }.to change{ player2.queen[0].current_position }.from(nil).to([0, 6])
      end

      it 'does not change the position of the other pieces' do
        other_locations = player2.piece_locations.delete(player2.pawn[5].current_position)
        other_locations = player2.piece_locations.delete(player2.queen[0].current_position)
        expect{ promotion }.not_to change{ other_locations }
      end

      it 'prints the message in which player two makes a move' do
        promotion
        msg = "Player 2 just made this move => xg1=Q"
        expect{game.parse_notation(player2)}.to output(include(msg)).to_stdout
      end
    end

    context 'when the pawn of player one at f5 makes an en passant move to g6' do
      before do
        board.layout[2][2] = board.layout[0][1]
        board.layout[0][1] = nil
        board.layout[2][2].current_position = [2, 2]

        board.layout[4][2] = board.layout[0][6]
        board.layout[0][6] = nil
        board.layout[4][2].current_position = [4, 2]

        allow(player1).to receive(:make_choice).and_return('Ne4')
      end

      let(:action) { game.parse_notation(player1) }
      let(:notation) { ["N", "", "", "e4", "", nil] }

      context 'when the notation has not specified which knight' do
        it 'returns the player number as 0 (i.e., player one)' do
          expect(game.player_turn(player1)).to eq(0)
        end

        it 'returns the parsed notation as ["N", "", "", "e4", "", nil]' do
          expect(game.prompt_notation(1, player1)).to eq(notation)
        end

        it 'triggers the reset pawn method' do
          expect(game).to receive(:reset_pawn).with(player1)
          allow(player1).to receive(:make_choice).and_return('N5e4')
          action
        end

        it 'does not trigger the invalid notation method' do
          expect(game).not_to receive(:invalid_notation).with(notation, player1)
        end

        it 'returns the values for the parameters within process notation method' do
          expect(game).to receive(:process_notation) do |piece_stats, move_elements, player, king, rook|
            expect(player).to eq(player1)
            expect(move_elements).to eq(notation)
            expect(king).to be_nil
            expect(rook).to be_nil
          end
          action
        end

        it 'does not change the knights\' positions' do
          allow(player1).to receive(:make_choice).and_return('N5e4')
          expect{ action }.not_to change{ player1.knight[0].current_position }
          expect{ action }.not_to change{ player1.knight[1].current_position }
        end

        it 'prints the error message' do
          msg = "\nThere are 2 pieces that can make the move. Please specify."
          expect{ game.process_notation(PIECE_STATS, notation, player1, nil, nil) }.to output(include(msg)).to_stdout
        end
      end
    end

    context 'when player one enters an invalid notation attempting to move the bishop at f1' do
      before do
        board.layout[2][4] = board.layout[1][4]
        board.layout[1][4] = nil
        board.layout[2][4].current_position = [2, 4]

        allow(player1).to receive(:make_choice).and_return('Beat')
      end

      let(:action) { game.parse_notation(player1) }

      context 'when the notation is not valid' do
        it 'returns the player number as 0 (i.e., player one)' do
          expect(game.player_turn(player1)).to eq(0)
        end

        it 'returns nil' do
          expect(game.prompt_notation(1, player1)).to be_nil
        end

        it 'triggers the reset pawn method' do
          expect(game).to receive(:reset_pawn).with(player1)
          allow(player1).to receive(:make_choice).and_return('Bc4')
          action
        end

        it 'returns true on the invalid notation method and prints error message' do
          expect(game.invalid_notation(nil, player1)).to be(true)
          msg = "It not a valid chess notation. Please try again.\n"
          expect{game.invalid_notation(nil, player1)}.to output(msg).to_stdout
        end

        it 'returns the values for the parameters within process notation method' do
          expect(game).not_to receive(:process_notation)
        end
      end
    end
  end

  describe '#reveal_move' do
    context 'when player 1 enters 0-0-0' do
      it 'prints that player 1 made the move 0-0-0' do
        player1.notation = ['', '', '', '', '', '0-0-0']
        msg = "\nPlayer 1 just made this move => 0-0-0\n\n"
        expect { game.reveal_move(1, player1) }.to output(msg).to_stdout
      end
    end

    context 'when player 2 enters e1=N' do
      it 'prints that player 1 made the move e1=Q' do
        player1.notation = ['', '', '', 'e1', '=Q', nil]
        msg = "\nPlayer 1 just made this move => e1=Q\n\n"
        expect { game.reveal_move(1, player1) }.to output(msg).to_stdout
      end
    end
  end

  describe '#prompt_notation' do
    context 'when player 1 is prompted to enter notation' do
      context 'when player enters e4 as the move' do
        it 'displays the board, asks player 1 to enter the move and return the move notation in array' do
          output = StringIO.new
          $stdout = output

          expect(board).to receive(:display_board)

          game.prompt_notation(1, player1)

          $stdout = STDOUT
          expect(output.string).to include("\nPlayer 1, please enter your move:")

          allow(player1).to receive(:make_choice).and_return('e8=Q')
          expect(game.retrieve_notation(player1)).to eq(['', '', '', 'e8', '=Q', nil])
        end
      end
    end

    context 'when player 1 is prompted to enter notation' do
      context 'when player enters Ze1xf4 as the move' do
        it 'displays the board, asks player 1 to enter the move and return nil' do
          output = StringIO.new
          $stdout = output

          expect(board).to receive(:display_board)

          game.prompt_notation(1, player1)

          $stdout = STDOUT
          expect(output.string).to include("\nPlayer 1, please enter your move:")

          allow(player1).to receive(:make_choice).and_return('Ze1xf4')
          expect(game.retrieve_notation(player1)).to be_nil
        end
      end
    end
  end

  describe '#introduce_computer' do
    context 'when the method is called' do
      it 'displays the board and announces the computer turn' do
        output = StringIO.new
        $stdout = output

        expect(board).to receive(:display_board)

        game.introduce_computer

        $stdout = STDOUT
        expect(output.string).to include("It is now Player 2's turn to move.")
      end
    end
  end

  describe '#retrieve_notation' do
    context 'when the castling notation 0-0-0 is entered' do
      it 'it returns 0-0-0' do
        expect(player1).to receive(:make_choice).and_return('0-0-0')
        expect(game.retrieve_notation(player1)).to eq([nil, nil, nil, nil, nil, '0-0-0'])
      end
    end

    context 'when the capture notation Ngxf3 is entered' do
      it 'it returns 0-0-0' do
        expect(player1).to receive(:make_choice).and_return('Ngxf3')
        expect(game.retrieve_notation(player1)).to eq(['N', 'g', 'x', 'f3', '', nil])
      end
    end

    context 'when the promotion notation f7=Q is entered' do
      it 'it returns f7=Q' do
        expect(player1).to receive(:make_choice).and_return('f7=Q')
        expect(game.retrieve_notation(player1)).to eq(['', '', '', 'f7', '=Q', nil])
      end
    end

    context 'when invalid notation is entered' do
      it 'it returns nil' do
        expect(player1).to receive(:make_choice).and_return('woriejio3')
        expect(game.retrieve_notation(player1)).to be_nil
      end
    end
  end

  describe '#invalid_notation' do
    context 'when the first player (human) enters nothing' do
      it 'returns true for invalid notation' do
        expect(game.invalid_notation(nil, player1)).to be(true)
        msg = "It not a valid chess notation. Please try again.\n"
        expect { game.invalid_notation(nil, player1) }.to output(msg).to_stdout
      end
    end

    context 'when the second player (computer) enters an valid string' do
      it 'returns true' do
        expect(game.invalid_notation(['N', 'h3', '', '', '', ''], player2)).to be(false)
        msg = "It not a valid chess notation. Please try again.\n"
        expect { game.invalid_notation(nil, player2) }.not_to output(msg).to_stdout
      end
    end
  end
end
