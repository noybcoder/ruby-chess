# frozen_string_literal: true

RSpec.describe Serializable do
  let(:game) { Game.new }

  before do
    Player.player_count = 0
    Board.board_count = 0
    allow_any_instance_of(Human).to receive(:make_choice).and_return("2\n")

    allow($stdout).to receive(:write)
  end

  matcher :be_unicode do |char|
    match { |p| p.unicode == char }
  end

  matcher :be_current do
    match(&:current_position)
  end

  describe '#gather_variables' do
    context 'when the game object is selected' do
      it 'returns the instance variables of game' do
        variables = %i[@player1 @player2 @board]
        expect(game.gather_variables(game)).to contain_exactly(*variables)
      end
    end

    context 'when the human (first player) object is selected' do
      it 'returns the instance variables of human (player1)' do
        variables = %i[@king @queen @rook @bishop @knight @pawn @notation]
        expect(game.gather_variables(game.player1)).to contain_exactly(*variables)
      end
    end

    context 'when the human (second player) object is selected' do
      before { allow(game.player1).to receive(:make_choice).and_return("1\n") }
      it 'returns the instance variables of human (player2)' do
        variables = %i[
          @available_destinations @bishop @king @knight
          @notation @pawn @player_count @queen @rook
        ]
        expect(game.gather_variables(game.player2)).to contain_exactly(*variables)
      end
    end

    context 'when the computer (second player) object is selected' do
      it 'returns the instance variables computer (player2)' do
        variables = %i[
          @available_destinations @bishop @king @knight
          @notation @pawn @player_count @queen @rook
        ]
        expect(game.gather_variables(game.player2)).to contain_exactly(*variables)
      end
    end

    context 'when the board object is selected' do
      it 'returns the instance variables of board' do
        variables = %i[@background_colors @board_count @color_offset @files @layout @ranks]
        expect(game.gather_variables(game.board)).to contain_exactly(*variables)
      end
    end
  end

  describe '#organize_variables' do
    let(:variables) { game.send(:organize_variables, game) }

    context 'when the game object is selected' do
      it 'contains the player1, player2 and board instances' do
        expect(variables.keys).to contain_exactly(:@player1, :@player2, :@board)
      end

      context 'when the player1 instance within the game object is examined' do
        let(:instance) { variables[:@player1] }
        it 'returns an instance of the Human class' do
          expect(instance).to be_a(Human)
        end

        it 'contains exactly the instance variables king, queen, rook, bishop, knight, pawn and notation' do
          vars = %i[@king @queen @rook @bishop @knight @pawn @notation]
          expect(instance.instance_variables).to contain_exactly(*vars)
        end

        it 'returns an array of nils for the notation' do
          expect(instance.notation).to all(be_nil)
        end

        it 'contains one king that is at e1' do
          king = instance.king
          expect(king.count).to eq(1)
          expect(king[0].unicode).to eq('♔')
          expect(king[0].current_position).to eq([0, 4])
          expect(king[0].queen_castling).to eq([0, 2])
          expect(king[0].king_castling).to eq([0, 6])
        end

        it 'contains one queen that is at d1' do
          queen = instance.queen
          expect(queen.count).to eq(1)
          expect(queen[0].unicode).to eq('♕')
          expect(queen[0].current_position).to eq([0, 3])
        end

        it 'contains two rooks at a1 and h1' do
          rook = instance.rook
          expect(rook.count).to eq(2)
          expect(rook).to all(be_unicode('♖'))
          expect(rook.map(&:current_position)).to eq([[0, 0], [0, 7]])
          expect(rook.map(&:queen_castling).uniq).to contain_exactly([0, 3])
          expect(rook.map(&:king_castling).uniq).to contain_exactly([0, 5])
        end

        it 'contains two bishops at c1 and f1' do
          bishop = instance.bishop
          expect(bishop.count).to eq(2)
          expect(bishop).to all(be_unicode('♗'))
          expect(bishop.map(&:current_position)).to eq([[0, 2], [0, 5]])
        end

        it 'contains two knights at b1 and g1' do
          knight = instance.knight
          expect(knight.count).to eq(2)
          expect(knight).to all(be_unicode('♘'))
          expect(knight.map(&:current_position)).to eq([[0, 1], [0, 6]])
        end

        it 'contains eight pawns from a2 to h2' do
          pawn = instance.pawn
          double_steps = [[3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7]]
          expect(pawn.count).to eq(8)
          expect(pawn).to all(be_unicode('♙'))
          locations = Array.new(8, 1).zip(Array(0..7))
          expect(pawn.map(&:current_position)).to eq(locations)
          expect(pawn.map(&:continuous_movement)).to all(be(true))
          expect(pawn.map { |p| p.double_step[0] }).to eq(double_steps)
          expect(pawn.map { |p| p.double_step[1] }).to all(be(false))
        end
      end

      context 'when the player2 instance within the game object is examined' do
        let(:instance) { variables[:@player2] }
        it 'returns an instance of the Computer class' do
          expect(instance).to be_a(Computer)
        end

        it 'contains exactly the instance variables king, queen, rook, bishop, knight, pawn and notation' do
          vars = %i[@available_destinations @king @queen @rook @bishop @knight @pawn @notation]
          expect(instance.instance_variables).to contain_exactly(*vars)
        end

        it 'returns nil for avialalbe destinations' do
          expect(instance.available_destinations).to be_nil
        end

        it 'returns an array of nils for the notation' do
          expect(instance.notation).to all(be_nil)
        end

        it 'contains one king that is at e8' do
          king = instance.king
          expect(king.count).to eq(1)
          expect(king[0].unicode).to eq('♚')
          expect(king[0].current_position).to eq([7, 4])
          expect(king[0].queen_castling).to eq([7, 2])
          expect(king[0].king_castling).to eq([7, 6])
        end

        it 'contains one queen that is at d8' do
          queen = instance.queen
          expect(queen.count).to eq(1)
          expect(queen[0].unicode).to eq('♛')
          expect(queen[0].current_position).to eq([7, 3])
        end

        it 'contains two rooks at a8 and h8' do
          rook = instance.rook
          expect(rook.count).to eq(2)
          expect(rook).to all(be_unicode('♜'))
          expect(rook.map(&:current_position)).to eq([[7, 0], [7, 7]])
          expect(rook.map(&:queen_castling).uniq).to contain_exactly([7, 3])
          expect(rook.map(&:king_castling).uniq).to contain_exactly([7, 5])
        end

        it 'contains two bishops at c8 and f8' do
          bishop = instance.bishop
          expect(bishop.count).to eq(2)
          expect(bishop).to all(be_unicode('♝'))
          expect(bishop.map(&:current_position)).to eq([[7, 2], [7, 5]])
        end

        it 'contains two knights at b8 and g8' do
          knight = instance.knight
          expect(knight.count).to eq(2)
          expect(knight).to all(be_unicode('♞'))
          expect(knight.map(&:current_position)).to eq([[7, 1], [7, 6]])
        end

        it 'contains eight pawns from a7 to h7' do
          pawn = instance.pawn
          double_steps = [[4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7]]
          expect(pawn.count).to eq(8)
          expect(pawn).to all(be_unicode('♟'))
          locations = Array.new(8, 6).zip(Array(0..7))
          expect(pawn.map(&:current_position)).to eq(locations)
          expect(pawn.map(&:continuous_movement)).to all(be(true))
          expect(pawn.map { |p| p.double_step[0] }).to eq(double_steps)
          expect(pawn.map { |p| p.double_step[1] }).to all(be(false))
        end
      end

      context 'when the board instance within the game object is examined' do
        let(:instance) { variables[:@board] }

        it 'returns an instance of the Board class' do
          expect(instance).to be_a(Board)
        end

        it 'contains exactly the instance variables background colors, color offset, files, layout, and ranks' do
          vars = %i[@background_colors @color_offset @files @layout @ranks]
          expect(instance.instance_variables).to contain_exactly(*vars)
        end

        it 'returns the background colors' do
          expect(instance.background_colors).to eq(["\e[48;2;222;184;135m", "\e[48;2;255;248;220m"])
        end

        it 'returns the color offset' do
          expect(instance.color_offset).to eq("\e[0m")
        end

        it 'returns the files' do
          expect(instance.files).to eq(Array('a'..'h'))
        end

        it 'returns the ranks' do
          expect(instance.ranks).to eq(Array(1..8))
        end

        context 'when it comes to the layout of the board' do
          let(:layout) { instance.layout }
          it 'returns 64 cells on the board' do
            expect(layout.flatten.count).to eq(64)
          end

          it 'returns 8 files and ranks' do
            expect(layout.count).to eq(8)
            expect(layout).to all(have_attributes(size: 8))
          end

          it 'returns 2 rooks at a1 and h1' do
            expect(layout[0].values_at(0, 7)).to all(be_a(Rook))
            expect(layout[0].values_at(0, 7)).to all(be_unicode('♖'))
          end

          it 'returns 2 knights at b1 and g1' do
            expect(layout[0].values_at(1, 6)).to all(be_a(Knight))
            expect(layout[0].values_at(1, 6)).to all(be_unicode('♘'))
          end

          it 'returns 2 bishops at c1 and f1' do
            expect(layout[0].values_at(2, 5)).to all(be_a(Bishop))
            expect(layout[0].values_at(2, 5)).to all(be_unicode('♗'))
          end

          it 'returns 1 queen at d1' do
            expect(layout[0][3]).to be_a(Queen)
            expect(layout[0][3]).to be_unicode('♕')
          end

          it 'returns 1 king at e1' do
            expect(layout[0][4]).to be_a(King)
            expect(layout[0][4]).to be_unicode('♔')
          end

          it 'returns 8 pawns from a2 to h2' do
            expect(layout[1]).to all(be_a(Pawn))
            expect(layout[1]).to all(be_unicode('♙'))
          end

          it 'returns nil from a3 to h6' do
            expect(layout[2..5].flatten).to all(be_nil)
          end

          it 'returns 2 rooks at a8 and h8' do
            expect(layout[7].values_at(0, 7)).to all(be_a(Rook))
            expect(layout[7].values_at(0, 7)).to all(be_unicode('♜'))
          end

          it 'returns 2 knights at b8 and g8' do
            expect(layout[7].values_at(1, 6)).to all(be_a(Knight))
            expect(layout[7].values_at(1, 6)).to all(be_unicode('♞'))
          end

          it 'returns 2 bishops at c8 and f8' do
            expect(layout[7].values_at(2, 5)).to all(be_a(Bishop))
            expect(layout[7].values_at(2, 5)).to all(be_unicode('♝'))
          end

          it 'returns 1 queen at d8' do
            expect(layout[7][3]).to be_a(Queen)
            expect(layout[7][3]).to be_unicode('♛')
          end

          it 'returns 1 king at e8' do
            expect(layout[7][4]).to be_a(King)
            expect(layout[7][4]).to be_unicode('♚')
          end

          it 'returns 8 pawns from a7 to h8' do
            expect(layout[6]).to all(be_a(Pawn))
            expect(layout[6]).to all(be_unicode('♟'))
          end
        end
      end
    end
  end

  describe '#serialize' do
    context 'when the background colors within the board instance is serialized' do
      it 'returns the serialized form' do
        output = "\x04\b[\aI\"\x18\e[48;2;222;184;135m\x06:\x06ETI\"\x18\e[48;2;255;248;220m\x06;\x00T"
        expect(game.serialize(game.board.background_colors)).to eq(output)
      end
    end

    context 'when the background colors within the board instance is serialized' do
      it 'returns the serialized form' do
        output = "\x04\b[\rI\"\x06a\x06:\x06ETI\"\x06b\x06;\x00TI\"\x06c\x06;\x00TI\"\x06d\x06;\x00TI\"\x06e\x06;\x00TI\"\x06f\x06;\x00TI\"\x06g\x06;\x00TI\"\x06h\x06;\x00T"
        expect(game.serialize(game.board.files)).to eq(output)
      end
    end

    context 'when the notation within the player1 instance is serialized' do
      it 'returns the serialized form' do
        game.player1.notation = ['', '', '', '', '', 'O-O']
        output = "\x04\b[\vI\"\x00\x06:\x06ET@\x06@\x06@\x06@\x06I\"\bO-O\x06;\x00T"
        expect(game.serialize(game.player1.notation)).to eq(output)
      end
    end

    context 'when the available destinations within the player2 instance is serialized' do
      it 'returns the serialized form' do
        game.player2.available_destinations = [[6, 2], [6, 4], [6, 6], [7, 1], [7, 5], [7, 6], [7, 7]]
        output = "\x04\b[\f[\ai\vi\a[\ai\vi\t[\ai\vi\v[\ai\fi\x06[\ai\fi\n[\ai\fi\v[\ai\fi\f"
        expect(game.serialize(game.player2.available_destinations)).to eq(output)
      end
    end
  end

  describe '#class_name' do
    context 'when the game instance is passed' do
      it 'returns the Game class' do
        expect(game.class_name(Game)).to eq(Game)
      end
    end

    context 'when the human instance is passed' do
      it 'returns the Human class' do
        expect(game.class_name(Human)).to eq(Human)
      end
    end

    context 'when the computer instance is passed' do
      it 'returns the Computer class' do
        expect(game.class_name(Computer)).to eq(Computer)
      end
    end

    context 'when the board instance is passed' do
      it 'returns the Board class' do
        expect(game.class_name(Board)).to eq(Board)
      end
    end

    context 'when the pawn instance is passed' do
      it 'returns the Pawn class' do
        expect(game.class_name(Pawn)).to eq(Pawn)
      end
    end

    context 'when the king instance is passed' do
      it 'returns the King class' do
        expect(game.class_name(King)).to eq(King)
      end
    end
  end

  describe '#class_variable' do
    context 'when the Board class is passed' do
      it 'returns the variable board_count' do
        expect(game.class_variable(Board)).to eq(:@board_count)
      end
    end

    context 'when the Player class is passed' do
      it 'returns the variable player_count' do
        expect(game.class_variable(Player)).to eq(:@player_count)
      end
    end

    context 'when the Human class is passed' do
      it 'returns nil' do
        expect(game.class_variable(Human)).to be_nil
      end
    end

    context 'when the Computer class is passed' do
      it 'returns nil' do
        expect(game.class_variable(Computer)).to eq(:@player_count)
      end
    end

    context 'when the Pawn class is passed' do
      it 'returns nil' do
        expect(game.class_variable(Pawn)).to be_nil
      end
    end

    context 'when the Knight class is passed' do
      it 'returns nil' do
        expect(game.class_variable(Knight)).to be_nil
      end
    end
  end

  describe '#class_method' do
    context 'when the Board class is passed' do
      it 'returns the variable board_count' do
        expect(game.class_method(Board)).to eq('board_count')
      end
    end

    context 'when the Player class is passed' do
      it 'returns the variable player_count' do
        expect(game.class_method(Player)).to eq('player_count')
      end
    end

    context 'when the Human class is passed' do
      it 'returns nil' do
        expect(game.class_method(Human)).to eq('')
      end
    end

    context 'when the Computer class is passed' do
      it 'returns nil' do
        expect(game.class_method(Computer)).to eq('player_count')
      end
    end

    context 'when the Pawn class is passed' do
      it 'returns nil' do
        expect(game.class_method(Pawn)).to eq('')
      end
    end

    context 'when the Knight class is passed' do
      it 'returns nil' do
        expect(game.class_method(Knight)).to eq('')
      end
    end
  end

  describe '#decrement_variable_count' do
    context 'when the Board class is passed' do
      it 'changes the variable board_count from 1 to 0' do
        expect(game.decrement_variable_count(Board)).to eq(0)
      end
    end

    context 'when the Player class is passed' do
      it 'changes the variable player_count from 2 to 1' do
        expect(game.decrement_variable_count(Player)).to eq(1)
      end
    end

    context 'when the Computer class is passed' do
      it 'changes the variable player_count from 1 to 0' do
        expect(game.decrement_variable_count(Computer)).to eq(0)
      end
    end
  end

  describe '#deserialize' do
    before do
      game.player1.notation = ['N', 'f3', '', 'd2', '', nil]
      game.player2.available_destinations = [
        [7, 1], [6, 4], [5, 0], [5, 1], [5, 2], [5, 3], [5, 4],
        [5, 5], [5, 6], [5, 7], [4, 0], [4, 4], [3, 1], [3, 3]
      ]

      game.board.layout[5][2] = game.board.layout[7][1]
      game.board.layout[7][1] = nil
      game.board.layout[5][2].current_position = [5, 2]

      game.board.layout[6][4].current_position = nil
      game.board.layout[6][4] = nil

      game.board.layout[1][3].current_position = nil
      game.board.layout[1][3] = nil

      game.board.layout[2][2] = game.board.layout[0][3]
      game.board.layout[0][3] = nil
      game.board.layout[2][2].current_position = [2, 2]

      game.board.layout[2][5] = game.board.layout[0][6]
      game.board.layout[0][6] = nil
      game.board.layout[2][5].current_position = [2, 5]
    end

    let(:current_state) { game.organize_variables(game) }
    let(:saved_data) { game.serialize(current_state[:@player1]) }
    let(:saved_data) { Marshal.dump(game.player1.notation) }

    # context '' do
    #   it '' do
    #     expect(game.deserialize(game, saved_data)).to eq()
    #   end
    # end
  end
end
