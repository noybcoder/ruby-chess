# frozen_string_literal: true

require './lib/board'
require './lib/errors'

RSpec.describe Board do
  subject(:board) { described_class.new }

  before do
    described_class.board_count = 0
    allow($stdout).to receive(:write)
  end

  describe '#initialize' do
    context 'when the board object is first instantiated' do
      it 'creates an 8x8 layout' do
        expect(board.layout.size).to eq(8)
        expect(board.layout.all? { |row| row.size == 8 }).to be true
        expect(board.layout.flatten.count).to eq(64)
      end

      it 'creates 8 files and 8 ranks' do
        expect(board.ranks).to eq(Array(1..8))
        expect(board.files).to eq(Array('a'..'h'))
      end
    end

    context 'when only one board object is instantiated' do
      before do
        described_class.board_count = 0
      end

      it 'does not raise any error' do
        expect { described_class.new }.not_to raise_error
      end

      it 'increases the board count by 1' do
        expect { described_class.new }.to change { described_class.board_count }.by(1)
      end
    end

    context 'when more than one board object is instantiated' do
      before do
        described_class.new
      end

      it 'raises BoardLimitViolation error and prints the error message' do
        msg = 'Chess only allows 1 board.'
        expect { described_class.new }.to raise_error(CustomErrors::BoardLimitViolation, msg)
      end

      it 'does not alter board count at all' do
        expect(described_class.board_count).to eq(1)
      end
    end
  end

  describe '#display_board' do
    context 'when the chess boad is empty' do
      let(:expected_output) do
        <<~BOARD
             a   b   c   d   e   f   g   h
          8                                  8
          7                                  7
          6                                  6
          5                                  5
          4                                  4
          3                                  3
          2                                  2
          1                                  1
             a   b   c   d   e   f   g   h
        BOARD
      end

      it 'prints the ranks and files of the empty board' do
        allow(board).to receive(:board_content) do |_rank|
          Array.new(8) { '    ' }
        end
        expect { board.display_board }.to output(expected_output).to_stdout
      end
    end

    context 'when pieces are present' do
      before do
        # Stub a piece at position a8 (rank 8, file a)
        0.upto(7) do |idx|
          piece = double('Pawn', unicode: '♙', current_position: [1, idx])
          board.layout[1][idx] = piece
        end

        def capture_stdout
          original_stdout = $stdout
          fake_terminal = StringIO.new
          $stdout = fake_terminal # Redirect all output to our fake terminal
          yield
          fake_terminal.string
        ensure
          $stdout = original_stdout
        end
      end

      it 'displays pawns in rank 2' do
        expect { board.display_board }.to output(/2 .*♙.*2/m).to_stdout
      end

      it 'shows exactly 8 pawns in rank 2' do
        printed_output = capture_stdout { board.display_board }
        pawn_count = printed_output.count('♙')
        expect(pawn_count).to eq(8)
      end
    end
  end

  describe '#board_content' do
    context 'when the first rank of an empty board is generated' do
      it 'returns the unicode characters in the first rank' do
        rank_content = [
          "\e[48;2;255;248;220m    \e[0m", "\e[48;2;222;184;135m    \e[0m",
          "\e[48;2;255;248;220m    \e[0m", "\e[48;2;222;184;135m    \e[0m",
          "\e[48;2;255;248;220m    \e[0m", "\e[48;2;222;184;135m    \e[0m",
          "\e[48;2;255;248;220m    \e[0m", "\e[48;2;222;184;135m    \e[0m"
        ]
        expect(board.board_content(1)).to eq(rank_content)
      end
    end

    context 'when the last rank of an empty board is generated' do
      it 'returns the unicode charactes in the last rank' do
        rank_content = [
          "\e[48;2;222;184;135m    \e[0m", "\e[48;2;255;248;220m    \e[0m",
          "\e[48;2;222;184;135m    \e[0m", "\e[48;2;255;248;220m    \e[0m",
          "\e[48;2;222;184;135m    \e[0m", "\e[48;2;255;248;220m    \e[0m",
          "\e[48;2;222;184;135m    \e[0m", "\e[48;2;255;248;220m    \e[0m"
        ]
        expect(board.board_content(8)).to eq(rank_content)
      end
    end
  end
end
