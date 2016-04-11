require 'rails_helper'

describe GamesController do
  it 'initializes games with a secret word' do
    data = {
        secret: 'hostel'
    }
    post :create, data

    expect(response).to be_success
  end
end