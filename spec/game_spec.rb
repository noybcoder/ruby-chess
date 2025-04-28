# frozen_string_literal: true

require './lib/game'
require './lib/player'
require './lib/serializable'

RSpec.describe Game do
  subject(:game) { described_class.new }

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
          expect(game.player1).to be_a(Human)
          expect(Player.player_count).to eq(1)
        end
      end

      context 'when the first player selects human as the second player' do
        it 'returns a human as the second player and total number of players as 2' do
          allow_any_instance_of(Human).to receive(:make_choice).and_return("1\n")
          expect(game.opponent_choice).to eq(1)
          expect(game.player2).to be_a(Human)
          expect(Player.player_count).to eq(2)
        end
      end

      context 'when the first player enters wrong input twice and computer as the second player' do
        it 'puts the prompt message 4 times and returns a computer as the second player' do
          allow_any_instance_of(Human).to receive(:make_choice).and_return("fqe\n", "\n", "2\n")
          msg = "Whom would you like to play against? Enter \"1\" for human or \"2\" for computer?\n"
          expect{ game.opponent_choice }.to output(msg * 4).to_stdout
          expect(game.player2).to be_a(Computer)
        end
      end

      context 'when the first player selects computer as the second player' do
        it 'returns a computer as the second player and total number of players as 2' do
          expect(game.opponent_choice).to eq(2)
          expect(game.player2).to be_a(Computer)
          expect(Player.player_count).to eq(2)
        end
      end

      context 'when the board is created along with the game' do
        it 'returns a board and total number of boards as 1' do
          expect(game.board).to be_a(Board)
          expect(Board.board_count).to eq(1)
        end
      end

      context 'when the method set_up_board is called' do
        it 'returns 64 cells in the board' do
          expect(game.board.layout.flatten.count).to eq(64)
        end

        it 'returns the pawn pieces for player 1 at rank 2' do
          result = game.board.layout[1].flatten
          expect(result).to all(be_a(Pawn))
          expect(result).to all(be_character('♙'))
        end

        it 'returns the rook pieces for player 1 at rank 1 and files a and h' do
          result = game.board.layout[0].flatten.values_at(0, 7)
          expect(result).to all(be_a(Rook))
          expect(result).to all(be_character('♖'))
        end

        it 'returns the knight pieces for player 1 at rank 1 and files b and f' do
          result = game.board.layout[0].flatten.values_at(1, 6)
          expect(result).to all(be_a(Knight))
          expect(result).to all(be_character('♘'))
        end

        it 'returns the bishop pieces for player 1 at rank 1 and files c and e' do
          result = game.board.layout[0].flatten.values_at(2, 5)
          expect(result).to all(be_a(Bishop))
          expect(result).to all(be_character('♗'))
        end

        it 'returns the queen piece for player 1 at rank 1 and file d' do
          result = game.board.layout[0][3]
          expect(result).to be_a(Queen)
          expect(result).to be_character('♕')
        end

        it 'returns the king piece for player 1 at rank 1 and file e' do
          result = game.board.layout[0][4]
          expect(result).to be_a(King)
          expect(result).to be_character('♔')
        end

        it 'returns nil for ranks 3 to 6' do
          expect(game.board.layout[2..5].flatten).to all(be_nil)
        end

        it 'returns the pawn pieces for player 2 at rank 6' do
          result = game.board.layout[6].flatten
          expect(result).to all(be_a(Pawn))
          expect(result).to all(be_character('♟'))
        end

        it 'returns the rook pieces for player 2 at rank 8 and files a and h' do
          result = game.board.layout[7].flatten.values_at(0, 7)
          expect(result).to all(be_a(Rook))
          expect(result).to all(be_character('♜'))
        end

        it 'returns the knight pieces for player 2 at rank 8 and files b and f' do
          result = game.board.layout[7].flatten.values_at(1, 6)
          expect(result).to all(be_a(Knight))
          expect(result).to all(be_character('♞'))
        end

        it 'returns the bishop pieces for player 2 at rank 8 and files c and e' do
          result = game.board.layout[7].flatten.values_at(2, 5)
          expect(result).to all(be_a(Bishop))
          expect(result).to all(be_character('♝'))
        end

        it 'returns the queen piece for player 2 at rank 8 and file d' do
          result = game.board.layout[7][3]
          expect(result).to be_a(Queen)
          expect(result).to be_character('♛')
        end

        it 'returns the king piece for player 2 at rank 8 and file e' do
          result = game.board.layout[7][4]
          expect(result).to be_a(King)
          expect(result).to be_character('♚')
        end
      end
    end
  end

  describe '#players' do
    context 'when the method is called' do
      it 'returns a 2-element array of players 1 and 2' do
        expect(game.players.count).to eq(2)
        expect(game.players[0]).to be(game.player1)
        expect(game.players[1]).to be(game.player2)
      end
    end
  end

  describe '#access_progress' do
    context 'when the access progress is defaulted to save the first player chooses not to save' do
      before do
        allow(game.player1).to receive(:make_choice).and_return("n\n")
      end

      it 'prompts the message asking the player if they want to save and returns "n" as the output' do
        msg = "\nWould you like to save your latest game progress? (y/n)\n"
        expect{game.access_progress}.to output(msg).to_stdout
        expect(game.access_progress).to eq("n\n")
        game.access_progress

      end
    end

    context 'when the access progress is defaulted to save the first player chooses to save' do
      before do
        allow(game.player1).to receive(:make_choice).and_return("y\n")
      end

      it 'prompts the message asking the player if they want to save and returns "y" as the output' do
        msg = "\nWould you like to save your latest game progress? (y/n)\n"
        expect{game.access_progress}.to output(msg).to_stdout
        expect(game.access_progress).to eq("y\n")
        game.access_progress

      end
    end

    context 'when the access progress is switched to load the first player chooses not to load' do
      before do
        allow(game.player1).to receive(:make_choice).and_return("n\n")
      end

      it 'prompts the message asking the player if they want to load and returns "n" as the output' do
        msg = "\nWould you like to load your latest game progress? (y/n)\n"
        expect{game.access_progress('load')}.to output(msg).to_stdout
        expect(game.access_progress('load')).to eq("n\n")
        game.access_progress

      end
    end

    context 'when the access progress is switched to load the first player chooses to load' do
      before do
        allow(game.player1).to receive(:make_choice).and_return("y\n")
      end

      it 'prompts the message asking the player if they want to load and returns "y" as the output' do
        msg = "\nWould you like to load your latest game progress? (y/n)\n"
        expect{game.access_progress('load')}.to output(msg).to_stdout
        expect(game.access_progress('load')).to eq("y\n")
        game.access_progress

      end
    end

    context 'when the first player enters something other y or n' do
      before do
        allow(game.player1).to receive(:make_choice).and_return("weroifjeoi\n", "y\n")
      end

      it 'prompts the message asking the player if they want to load and returns "y" as the output' do
        msg = "\nWould you like to load your latest game progress? (y/n)\n"
        expect{game.access_progress('load')}.to output(msg * 2).to_stdout
        expect(game.access_progress('load')).to eq("y\n")
        game.access_progress

      end
    end
  end

  describe '#player_turn' do
    context 'when player 1 is selected' do
      it 'returns the output 0' do
        expect(game.player_turn(game.player1)).to eq(0)
      end
    end

    context 'when player 2 is selected' do
      it 'returns the output 1' do
        expect(game.player_turn(game.player2)).to eq(1)
      end
    end
  end

  describe '#parse_notation' do
    context 'when the first player is prompted to enter the move and the move Nf3 is entered' do
      before do
        allow(game).to receive(:player_turn).with(game.player1).and_return(0)
        allow(game).to receive(:reveal_move)
        allow(game).to receive(:reset_pawn)
      end

      it 'exits after one valid input' do

        valid_elements = ['N', 'f3', '', '', '', '']

        allow(game).to receive(:prompt_notation).and_return(valid_elements)
        allow(game).to receive(:invalid_notation).and_return(false)
        allow(game).to receive(:process_notation).and_return(true)

        expect(game).to receive(:reveal_move).with(1, game.player1)
        expect(game.invalid_notation(valid_elements, game.player1)).to be(false)
        game.parse_notation(game.player1)
      end

    end
  end


  describe '#reveal_move' do
    context 'when player 1 enters 0-0-0' do
      it 'prints that player 1 made the move 0-0-0' do
        game.player1.notation = ['', '', '', '', '', '0-0-0']
        msg = "\nPlayer 1 just made this move => 0-0-0\n\n"
        expect{ game.reveal_move(1, game.player1) }.to output(msg).to_stdout
      end
    end

    context 'when player 2 enters e1=N' do
      it 'prints that player 1 made the move e1=Q' do
        game.player1.notation = ['', '', '', 'e1', '=Q', nil]
        msg = "\nPlayer 1 just made this move => e1=Q\n\n"
        expect{ game.reveal_move(1, game.player1) }.to output(msg).to_stdout
      end
    end

  end

  describe '#prompt_notation' do
    context 'when player 1 is prompted to enter notation' do
      context 'when player enters e4 as the move' do
        it 'displays the board, asks player 1 to enter the move and return the move notation in array' do
          output = StringIO.new
          $stdout = output

          expect(game.board).to receive(:display_board)

          game.prompt_notation(1, game.player1)

          $stdout = STDOUT
          expect(output.string).to include("\nPlayer 1, please enter your move:")

          allow(game.player1).to receive(:make_choice).and_return("e8=Q")
          expect(game.retrieve_notation(game.player1)).to eq(['', '', '', 'e8', '=Q', nil])
        end
      end
    end


    context 'when player 1 is prompted to enter notation' do
      context 'when player enters Ze1xf4 as the move' do
        it 'displays the board, asks player 1 to enter the move and return nil' do
          output = StringIO.new
          $stdout = output

          expect(game.board).to receive(:display_board)

          game.prompt_notation(1, game.player1)

          $stdout = STDOUT
          expect(output.string).to include("\nPlayer 1, please enter your move:")

          allow(game.player1).to receive(:make_choice).and_return("Ze1xf4")
          expect(game.retrieve_notation(game.player1)).to be_nil
          end
      end
    end
  end

  describe '#introduce_computer' do
    context 'when the method is called' do
      it 'displays the board and announces the computer turn' do
        output = StringIO.new
        $stdout = output

        expect(game.board).to receive(:display_board)

        game.introduce_computer

        $stdout = STDOUT
        expect(output.string).to include("It is now Player 2's turn to move.")
      end
    end
  end

  describe '#invalid_notation' do

    context 'when the first player (human) enters nothing' do
      it 'returns true for invalid notation' do
        expect(game.invalid_notation(nil, game.player1)).to be(true)
        msg = "It not a valid chess notation. Please try again.\n"
        expect{ game.invalid_notation(nil, game.player1) }.to output(msg).to_stdout
      end
    end

    context 'when the second player (computer) enters an valid string' do
      it 'returns true' do
        expect(game.invalid_notation(['N', 'h3', '', '', '', ''], game.player2)).to be(false)
        msg = "It not a valid chess notation. Please try again.\n"
        expect{ game.invalid_notation(nil, game.player2) }.not_to output(msg).to_stdout
      end
    end

  end
end
