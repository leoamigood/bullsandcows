require 'rails_helper'

describe Game, type: :model do
  let!(:channel1) { Random.rand(@MAX_INT_VALUE) }
  let!(:channel2) { Random.rand(@MAX_INT_VALUE) }

  context 'given recent games' do
    let!(:game1) { create(:game, channel: channel1, created_at: Time.now) }
    let!(:game2) { create(:game, channel: channel2, created_at: Time.now - 1.day) }
    let!(:game3) { create(:game, channel: channel1, created_at: Time.now - 5.days) }
    let!(:game4) { create(:game, channel: channel2, created_at: Time.now - 8.days) }

    it 'list games within last week for a channel' do
      expect(Game.recent(channel1, Time.now - 7.days)).to include(game1, game3)
      expect(Game.recent(channel1, Time.now - 7.days)).not_to include(game2, game4)
    end
  end
end
