require 'rails_helper'

describe Hooks::TelegramController do

  context 'when receives telegram message with /help command' do
    let!(:command) {
      {
          'update_id' => 215227398,
          'message' => {
              'message_id' => 117,
              'from' => {
                  'id' => 169778030,
                  'first_name' => 'Leo',
                  'username' => 'Amig0'
              },
              'chat' => {
                  'id' => 169778030,
                  'first_name' => 'Leo',
                  'username' => 'Amig0',
                  'type' => 'private'
              },
              'date' => 1475902767,
              'text' => '/help',
              'entities' => [{'type' => 'bot_command', 'offset' => 0, 'length' => 5}]
          },
          'controller' => 'hooks/telegram',
          'action' => 'update',
          'telegram' => {
              'update_id' => 215227398,
              'message' => {
                  'message_id' => 117,
                  'from' => {
                      'id' => 169778030,
                      'first_name' => 'Leo',
                      'username' => 'Amig0'
                  },
                  'chat' => {
                      'id' => 169778030,
                      'first_name' => 'Leo',
                      'username' => 'Amig0',
                      'type' => 'private'
                  },
                  'date' => 1475902767,
                  'text' => '/help',
                  'entities' => [{'type' => 'bot_command', 'offset' => 0, 'length' => 5}]
              }
          }
      }
    }

    it 'responds with help text' do
      post :update, command

      expect(response).to be_success
      expect(response.status).to be(200)

      body = JSON.parse(response.body)
      expect(body).to include('text' => /Here is the list of available commands/)
    end
  end

  context 'given dictionary with word levels' do
      let!(:dictionary) { create :dictionary, :words_with_levels, lang: 'RU'}

      context 'when receives telegram callback with /level command' do
        let!(:command) {
          {
              'update_id' => 215227400,
              'callback_query' => {
                  'id' => '729191086489033331',
                  'from' => {
                      'id' => 169778030,
                      'first_name' => 'Leo',
                      'username' => 'Amig0'
                  },
                  'message' => {
                      'message_id' => 120,
                      'from' => {
                          'id' => 263193518,
                          'first_name' => 'Bulls and Cows Words Bot',
                          'username' => 'bullsandcowswordsbot'
                      },
                      'chat' => {
                          'id' => 169778030,
                          'first_name' => 'Leo',
                          'username' => 'Amig0',
                          'type' => 'private'
                      },
                      'date' => 1475903668,
                      'text' => 'Select a game level:'
                  },
                  'chat_instance' => '-7110989980032921547',
                  'data' => '/level easy'
              },
              'controller' => 'hooks/telegram',
              'action' => 'update',
              'telegram' => {
                  'update_id' => 215227400,
                  'callback_query' => {
                      'id' => '729191086489033331',
                      'from' => {
                          'id' => 169778030,
                          'first_name' => 'Leo',
                          'username' => 'Amig0'
                      },
                      'message' => {
                          'message_id' => 120,
                          'from' => {
                              'id' => 263193518,
                              'first_name' => 'Bulls and Cows Words Bot',
                              'username' => 'bullsandcowswordsbot'
                          },
                          'chat' => {
                              'id' => 169778030,
                              'first_name' => 'Leo',
                              'username' => 'Amig0',
                              'type' => 'private'
                          },
                          'date' => 1475903668,
                          'text' => 'Select a game level:'
                      },
                      'chat_instance' => '-7110989980032921547',
                      'data' => '/level easy'
                  }
              }
          }
        }

        it 'creates a game with selected level' do
          post :update, command

          expect(response).to be_success
          expect(response.status).to be(200)

          body = JSON.parse(response.body)
          expect(body).to include('text' => /Game created/)
        end
      end
  end

end
