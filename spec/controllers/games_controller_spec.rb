require 'rails_helper'

describe GamesController do
  let!(:hostel) { create(:noun, noun: 'hostel') }

  it 'initializes games with a secret word' do
    data = {
        secret: 'hostel'
    }
    post :create, data

    expect(response).to be_success
  end
end