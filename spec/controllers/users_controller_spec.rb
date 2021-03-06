require 'rails_helper'

describe UsersController, :type => :controller do
  before do
    allow(session).to receive(:id).and_return(Random.rand(@MAX_INT_VALUE))
  end

  context 'given user without a session' do
    it 'creates new session and gets user details based on it' do
      get :me

      expect(json).to be
      expect(session.id).to be

      expect(json['user']).to be
      expect(json['user']['id']).to be
      expect(json['user']['link']).to be
    end
  end

  context 'given user with existing session' do
    let!(:user_session_id) { 'user-session-id' }
    let!(:user) { create :user, :web, ext_id: user_session_id }

    before do
      allow(session).to receive(:id).and_return(user_session_id)
    end

    it 'gets user details based on existing session' do
      get :me

      expect(json).to be
      expect(session.id).to eq(user_session_id)

      expect(json['user']).to be
      expect(json['user']['id']).to eq(user.id)
      expect(json['user']['link']).to eq("/users/#{user.id}")
    end
  end

end
