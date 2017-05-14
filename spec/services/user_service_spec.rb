require 'rails_helper'

describe UserService, type: :service do
  let!(:user) { build :user, :telegram, :john_smith }
  let!(:realm) { build :telegram_realm, user: user }

  let!(:message) { build :message, :with_realm, text: '/start', realm: realm }
  it 'create user from telegram message' do
    expect(UserService.create_from_telegram(message)).to have_attributes(username: 'john_smith', source: 'telegram')
  end

  let!(:session) { OpenStruct.new(id: 'web-session-id') }
  xit 'create user from web session' do
    expect(UserService.create_from_web(session)).to have_attributes(ext_id: session.id, source: 'web')
  end
end
