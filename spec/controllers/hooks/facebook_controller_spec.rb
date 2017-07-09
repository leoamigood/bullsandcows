require 'rails_helper'

describe Hooks::FacebookController, :type => :request do

  context 'when receives facebook message' do
    let!(:payload) {
      {
        'object' => 'page',
        'entry' => [{
             'id' => '118668095415628',
             'time' => 1499659268132,
             'messaging' => [{
                  'sender' => { 'id' => '1523536607709340' },
                  'recipient' => { 'id' => '118668095415628' },
                  'timestamp' => 1499659268089,
                  'message' => {
                      'mid' => 'mid.$cAAAxGwRIDl1jW-23-VdKqhvB-mTL',
                      'seq' => 681,
                      'text' => 'voodoo'
                  }
             }]
        }],
        'facebook' =>
          {
            'object' => 'page',
            'entry' => [{
                'id' => '118668095415628',
                'time' => 1499659268132,
                'messaging' => [{
                    'sender' => { 'id' => '1523536607709340' },
                    'recipient' => { 'id' => '118668095415628' },
                    'timestamp' => 1499659268089,
                    'message' => {
                        'mid' => 'mid.$cAAAxGwRIDl1jW-23-VdKqhvB-mTL',
                        'seq' => 681,
                        'text' => 'voodoo'
                    }
                }]
            }]
          }
      }.to_json
    }


    let!(:signature) {
      OpenSSL::HMAC.hexdigest(
          OpenSSL::Digest.new('sha1'),
          ENV['APP_SECRET'],
          payload
      )
    }

    it 'responds with provided challenge' do
      post '/hooks/facebook', params: payload, headers: { 'HTTP_X_HUB_SIGNATURE' => "sha1=#{signature}" }

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

end
