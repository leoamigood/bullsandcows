require 'rails_helper'

describe Hooks::TelegramController, :type => :request do
  let!(:chat_id) { 169778030 }
  let!(:queue) { Telegram::CommandQueue::Queue.new(chat_id) }

  after do
    queue.clear
  end

  context 'when receives telegram message with /start command' do
    before do
      allow(Telegram::TelegramMessenger).to receive(:send_message)
    end

    let!(:command) {
      {
          'update_id' => 215227450,
          'message' => {
              'message_id' => 214,
              'from' => {
                  'id' => chat_id,
                  'first_name' => 'Leo',
                  'username' => 'Amig0',
                  'language_code' => 'ru-Ru'
          },
              'chat' => {
                  'id' => chat_id,
                  'first_name' => 'Leo',
                  'username' => 'Amig0',
                  'type' => 'private'
          },
              'date' => 1476237972,
              'text' => '/start',
              'entities' => [{'type' => 'bot_command','offset' => 0,'length' => 6}]
          },
          'controller' => 'hooks/telegram',
          'action' => 'update',
          'telegram' => {
              'update_id' => 215227450,
              'message' => {
                  'message_id' => 214,
                  'from' => {
                      'id' => chat_id,
                      'first_name' => 'Leo',
                      'username' => 'Amig0'
              },
                  'chat' => {
                      'id' => chat_id,
                      'first_name' => 'Leo',
                      'username' => 'Amig0',
                      'type' => 'private'
              },
                  'date' => 1476237972,
                  'text' => '/start',
                  'entities' => [{'type' => 'bot_command','offset' => 0,'length' => 6}]
              }
          }
      }
    }

    it 'responds with game start' do
      expect {
        post "/hooks/telegram/#{ENV['TELEGRAM_WEBHOOK']}", params: command
      }.to change(queue, :size).by(3)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['text']).to eq('')
      expect(json['chat_id']).to eq(chat_id)
      expect(json['parse_mode']).to eq('Markdown')
      expect(json['method']).to eq('sendMessage')
    end
  end

  context 'when receives telegram message with /help command' do
    let!(:command) {
      {
          'update_id' => 215227398,
          'message' => {
              'message_id' => 117,
              'from' => {
                  'id' => chat_id,
                  'first_name' => 'Leo',
                  'username' => 'Amig0',
                  'language_code' => 'ru-Ru'
              },
              'chat' => {
                  'id' => chat_id,
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
                      'id' => chat_id,
                      'first_name' => 'Leo',
                      'username' => 'Amig0'
                  },
                  'chat' => {
                      'id' => chat_id,
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
      post "/hooks/telegram/#{ENV['TELEGRAM_WEBHOOK']}", params: command

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['text']).to match /Here is the list of available commands/
      expect(json['chat_id']).to eq(chat_id)
      expect(json['parse_mode']).to eq('Markdown')
      expect(json['method']).to eq('sendMessage')
    end
  end

  context 'when receives telegram message with non text message' do
    let!(:command) {
      {
          'update_id' => 215227398,
          'message' => {
              'message_id' => 117,
              'from' => {
                  'id' => chat_id,
                  'first_name' => 'Leo',
                  'username' => 'Amig0'
              },
              'chat' => {
                  'id' => chat_id,
                  'first_name' => 'Leo',
                  'username' => 'Amig0',
                  'type' => 'private'
              },
              'date' => 1475902767,
              'sticker'=>{
                  'width'=>512,
                  'height'=>512,
                  'emoji'=>'?',
                  'thumb'=>{
                      'file_id'=>'AAQCABPl_kcNAARhuKiTqw7TXDUWAAIC',
                      'file_size'=>5698,
                      'width'=>128,
                      'height'=>128},
                  'file_id'=>'CAADAgAD5AIAAnn_1AaG0dar1zK5xQI',
                  'file_size'=>37706
              },
              'entities' => [{'type' => 'bot_command', 'offset' => 0, 'length' => 5}]
          },
          'controller' => 'hooks/telegram',
          'action' => 'update',
          'telegram' => {
              'update_id' => 215227398,
              'message' => {
                  'message_id' => 117,
                  'from' => {
                      'id' => chat_id,
                      'first_name' => 'Leo',
                      'username' => 'Amig0'
                  },
                  'chat' => {
                      'id' => chat_id,
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
      post "/hooks/telegram/#{ENV['TELEGRAM_WEBHOOK']}", params: command

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['text']).to be_empty
      expect(json['chat_id']).to eq(chat_id)
      expect(json['parse_mode']).to eq('Markdown')
      expect(json['method']).to eq('sendMessage')
    end
  end

  context 'given dictionary with word levels' do
    let!(:ask_level) { Telegram::CommandQueue::Exec.new('Telegram::TelegramMessenger.ask_level', chat_id, Telegram::Action::Level.self?) }

    before do
      allow(Telegram::TelegramMessenger).to receive(:answerCallbackQuery)

      queue.push(ask_level)
    end

    let!(:dictionary) { create :dictionary, :english, lang: 'RU'}

    context 'when receives telegram callback with /level <level> command' do
      let!(:command) {
        {
            'update_id' => 215227400,
            'callback_query' => {
                'id' => '729191086489033331',
                'from' => {
                    'id' => chat_id,
                    'first_name' => 'John',
                    'last_name' => 'Smith',
                    'username' => 'john_smith'
                },
                'message' => {
                    'message_id' => 120,
                    'from' => {
                        'id' => 263193518,
                        'first_name' => 'Bulls and Cows Words Bot',
                        'username' => 'bullsandcowswordsbot'
                    },
                    'chat' => {
                        'id' => chat_id,
                        'first_name' => 'John',
                        'last_name' => 'Smith',
                        'username' => 'john_smith',
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
                        'id' => chat_id,
                        'first_name' => 'John',
                        'last_name' => 'Smith',
                        'username' => 'john_smith'
                    },
                    'message' => {
                        'message_id' => 120,
                        'from' => {
                            'id' => 263193518,
                            'first_name' => 'Bulls and Cows Words Bot',
                            'username' => 'bullsandcowswordsbot'
                        },
                        'chat' => {
                            'id' => chat_id,
                            'first_name' => 'John',
                            'last_name' => 'Smith',
                            'username' => 'john_smith',
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
        expect {
          post "/hooks/telegram/#{ENV['TELEGRAM_WEBHOOK']}", params: command
        }.to change(queue, :size).by(-1)

        expect(response).to be_success
        expect(response).to have_http_status(200)

        expect(json).to be
        expect(json['text']).to eq('Game level was set to easy.')
        expect(json['chat_id']).to eq(chat_id)
        expect(json['parse_mode']).to eq('Markdown')
        expect(json['method']).to eq('sendMessage')
      end
    end
  end

end
