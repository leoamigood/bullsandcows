module Facebook
  include Facebook::Messenger

  Bot.on :message do |message|
    FacebookDispatcher.execute(message.text, message.sender, message)
  end

  Bot.on :postback do |postback|
    postback.sender
    postback.recipient
    postback.sent_at
    postback.payload

    puts "Postback playload #{postback.payload}"

    if postback.payload == '/best'
      postback.reply(text: 'Here we will put best matches', metadata: '/best')
    end
  end

  unless Rails.env == 'test'
    Facebook::Messenger::Profile.set(
      {
        get_started: {
          payload: '/start'
        },
        greeting:[
          {
            locale: 'default',
            text: 'Bulls and Cows is a code-breaking mind game for one or more players. This is a words version.'
          },
          {
            locale: 'ru_RU',
            text: 'Быки и Коровы - логическая игра, в ходе которой игрок должен определить загаданное слово.'
          }
        ]
      }, access_token: ENV['ACCESS_TOKEN']
    )

    Facebook::Messenger::Profile.set(
      {
        persistent_menu: [
          {
            locale: 'default',
            composer_input_disabled: false,
            call_to_actions: [{
              title: 'Game',
              type: 'nested',
                call_to_actions: [
                  {
                    title: 'Start a new game',
                    type: 'postback',
                    payload: '/start'
                  },
                  {
                    title: 'Best matches',
                    type: 'postback',
                    payload: '/best'
                  },
                  {
                    title: 'Zero matches',
                    type: 'postback',
                    payload: '/zero'
                  },
                  {
                    title: 'Stop current game',
                    type: 'postback',
                    payload: '/stop'
                  }
                ]
              },
              {
                title: 'Settings',
                type: 'nested',
                call_to_actions: [
                  {
                    title: 'Top scores',
                    type: 'postback',
                    payload: '/score'
                  },
                  {
                    title: 'Trends',
                    type: 'postback',
                    payload: '/trend'
                  },
                  {
                    title: 'Language',
                    type: 'postback',
                    payload: '/score'
                  },
                  {
                    title: 'Level',
                    type: 'postback',
                    payload: '/level'
                  }
                ]
                }, {
                  type: 'web_url',
                  title: 'Rules',
                  url: 'https://en.wikipedia.org/wiki/Bulls_and_Cows',
                  webview_height_ratio: 'full'
                }
              ]
              }, {
                locale: 'ru_RU',
                composer_input_disabled: false
              }
            ]
        }, access_token: ENV['ACCESS_TOKEN']
    )
  end

end
