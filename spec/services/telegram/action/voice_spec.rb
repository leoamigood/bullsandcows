require 'rails_helper'

describe Telegram::Action::Voice, type: :service do
  let!(:john) { create :user, :telegram, :john_smith }
  let!(:chris) { create :user, :telegram, :chris_pooh }
  let!(:josef) { create :user, :telegram, :josef_gold }
  let!(:pavel) { create :user, :telegram, :pavel_durov }

  let!(:realm) { build :telegram_realm, user: john }

  let!(:message) { build :message, :with_realm, :voice_short, realm: realm }

  context 'with a running game' do
    let!(:english) { create :dictionary, :english}
    let!(:game) { create(:game, :realm, secret: 'secret', realm: realm, status: :created, dictionary: english) }

    it 'returns ' do
      expect(Telegram::Action::Voice.languageRegion(realm.channel, john)).to eq('en-GB')
      expect(Telegram::Action::Voice.languageRegion(realm.channel, chris)).to eq('en-US')
      expect(Telegram::Action::Voice.languageRegion(realm.channel, josef)).to eq('en-US')
      expect(Telegram::Action::Voice.languageRegion(realm.channel, josef)).to eq('en-US')
    end
  end

  it 'returns correct language region code' do
    expect(Telegram::Action::Voice.bcp47('en')).to eq('en-US')
    expect(Telegram::Action::Voice.bcp47('ru')).to eq('ru-RU')
    expect(Telegram::Action::Voice.bcp47('de')).to eq('de-DE')
  end
end
