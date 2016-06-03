class TelegramService

  @@WELCOME_MSG = 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'

  def self.start
    @@WELCOME_MSG
  end

  def self.create()
    secret = Noun.offset(rand(Noun.count)).first!.noun

    game = GameService.create(message.chat.id, secret, :telegram)
    "Game created with *#{game.secret.length}* letters in the secret word."
  end

  def self.create_by_word(word)
    secret = Noun.find_by_noun(word)
    raise "Word #{word} not found in the dictionary. Please try different secret word." unless secret.present?

    game = GameService.create(message.chat.id, secret.noun, :telegram)
    "Game created with *#{game.secret.length}* letters in the secret word."
  end

  def self.create_by_number(number)
    secret = Noun.where('char_length(noun) = ?', number).order('RANDOM()').first
    raise "Unable to create a game with #{number} letters word. Please try different amount." unless secret.present?

    game = GameService.create(message.chat.id, secret.noun, :telegram)
    "Game created with *#{game.secret.length}* letters in the secret word."
  end

  def self.guess(channel, username, word)
    game = Game.where(channel: channel).last
    raise "Failed to find the game. Is game started for telegram message chat ID: #{channel}" unless game.present?

    GameService.validate_game!(game)
    GameService.validate_guess!(game, word)

    guess = GameService.guess(game, username, word)

    text = "Guess: _#{word}_, *Bulls: #{guess.bulls}*, *Cows: #{guess.cows}*"
    text + "Congratulations! You guessed it with *#{guess.game.guesses.length}* tries" if game.finished?
  end

  def self.hint(channel)
    game = Game.where(channel: channel).last
    raise "Failed to find the game. Is game started for telegram message chat ID: #{channel}" unless game.present?

    GameService.validate_game!(game)
    letter = GameService.hint(game)

    "Secret word has letter _#{letter}_ in it"
  end

  def self.tries(channel)
    game = Game.where(channel: channel).last
    raise "Failed to find the game. Is game started for telegram message chat ID: #{message.chat.id}" unless game.present?

    unless (game.guesses.empty)
      text = tries.each_with_index.map do |guess, i|
        "Attempt #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
      end
      text.join("\n")
    else
      'There was no guesses so far. Go ahead and submit one with _/guess <word>_'
    end
  end

  def self.stop_permitted(bot, message)
    member = bot.api.getChatMember({chat_id: message.chat.id, user_id: message.from.id})
    status = member['result']['status']

    message.chat.type == 'group' ? status == 'creator' || status == 'administrator' : status == 'member'
  end

  def self.stop(message)
    game = Game.where(channel: message.chat.id).last
    raise "Failed to find the game. Is game started for telegram message chat ID: #{message.chat.id}" unless game.present?

    GameService.validate_game!(game)

    game.finished!
    game.save!

    "You give up? Here is the secret word *#{game.secret}*"
  end

  def self.help
    lines = ['Use _/create [number]_ to create a game', 'Use _/guess <word>_ to guess the secret word', 'Use _/tries_ to show previous attempts', 'Use _/hint_ reveals one letter']
    lines.join("\n")
  end

end