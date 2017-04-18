require 'rails_helper'

describe TelegramMessenger, type: :service do

  context 'given scores array' do
    let!(:scores) { [[3789732324, 234],[230472394, 189], [3462875423, 103]]}

    it 'validate top scores message' do
      expect(TelegramMessenger.top_scores(scores)).to include('1: User ID: 3789732324, Score: 234')
    end
  end

end
