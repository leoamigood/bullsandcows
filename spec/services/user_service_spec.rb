require 'rails_helper'

describe UserService, type: :service do

  context 'given a telegram message' do
    let!(:user) { build :user, :telegram, :john_smith }
    let!(:realm) { build :telegram_realm, user: user }

    let!(:message) { build :message, :with_realm, text: '/start', realm: realm }

    it 'create user from telegram message' do
      expect(UserService.create_from_telegram(message.from)).
          to have_attributes(
                 username: 'john_smith',
                 first_name: 'John',
                 last_name: 'Smith',
                 source: 'telegram',
                 language: nil
             )
    end
  end

  context 'given existing telegram user' do
    let!(:original) { create :user, :telegram, username: 'austin_powers', first_name: 'Austin', last_name: 'Powers', language: 'en-US'  }

    context 'given a telegram message by that user with updated properties' do
      let!(:user) { build :user, :web, :john_smith, ext_id: original.ext_id, language: 'ru-RU' }
      let!(:realm) { build :telegram_realm, user: user }

      let!(:message) { build :message, :with_realm, text: '/start', realm: realm }

      it 'update user properties, but keep telegram source' do
        expect(UserService.create_from_telegram(message.from)).
            to have_attributes(
                   username: 'john_smith',
                   first_name: 'John',
                   last_name: 'Smith',
                   language: 'ru-RU',
                   source: 'telegram'
               )
      end
    end
  end

  let!(:session) { OpenStruct.new(id: 'web-session-id') }
  xit 'create user from web session' do
    expect(UserService.create_from_web(session)).to have_attributes(ext_id: session.id, source: 'web')
  end
end
