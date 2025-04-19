# frozen_string_literal: true

require './lib/human'
require './lib/errors'

RSpec.describe Human do
  subject(:human) { described_class.new }

  describe '#make_choice' do
    before { Player.player_count = 0 }

    context 'when the command "e4" is entered' do
      it 'returns the string "e4"' do
        allow(human).to receive(:gets).and_return("e4\n")
        expect(human.make_choice).to eq('e4')
      end
    end

    context 'when the command "0-0-0" is entered' do
      it 'returns the string "0-0-0"' do
        allow(human).to receive(:gets).and_return("0-0-0\n")
        expect(human.make_choice).to eq('0-0-0')
      end
    end
  end
end
