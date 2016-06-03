require 'rails_helper'

describe 'Telegram Webhook API' do

  it 'creates a game with a word' do
    data = {
        "update_id" => 980057565,
        "message" => {
            "message_id" => 1181,
            "from" => {
                "id" => 169778030,
                "first_name" => "Leo",
                "username" => "Amig0"
            },
            "chat" => {
                "id" => 169778030,
                "first_name" => "Leo",
                "username" => "Amig0",
                "type" => "private"
            },
            "date" => 1464979319,
            "text" => "/help",
            "entities" => [{"type" => "bot_command", "offset" => 0, "length" => 5}]},
        "controller" => "hooks/telegram",
        "action" => "update",
        "telegram" => {
            "update_id" => 980057565,
            "message" => {
                "message_id" => 1181,
                "from" => {
                    "id" => 169778030,
                    "first_name" => "Leo",
                    "username" => "Amig0"
                },
                "chat" => {
                    "id" => 169778030,
                    "first_name" => "Leo",
                    "username" => "Amig0",
                    "type" => "private"
                },
                "date" => 1464979319,
                "text" => "/help",
                "entities" => [{"type" => "bot_command", "offset" => 0, "length" => 5}]}
        }
    }

    post "/hooks/telegram/#{ENV['TELEGRAM_WEBHOOK']}", data

    expect(response).to be_success
  end

end