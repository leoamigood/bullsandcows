class TelegramMessenger

  class << self
    def welcome
      'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'
    end

    def create(game)
      "Game created with *#{game.secret.length}* letters in the secret word."
    end

    def guess(guess)
      text = "Guess: _#{guess.word}_, *Bulls: #{guess.bulls}*, *Cows: #{guess.cows}*\n"
      text += "Congratulations! You guessed it with *#{guess.game.guesses.length}* tries" if guess.game.finished?

      text
    end

    def hint(letter)
      "Secret word has letter _#{letter}_ in it"
    end

    def tries(guesses)
      unless guesses.empty?
        text = guesses.each_with_index.map do |guess, i|
          "Try #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
        end
        text.join("\n")
      else
        self.no_guesses_submitted
      end
    end

    def best(guesses)
      unless guesses.empty?
        text = guesses.each_with_index.map do |guess, i|
          "Top #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
        end
        text.join("\n")
      else
        self.no_guesses_submitted
      end
    end

    def zeros(guesses)
      unless guesses.empty?
        text = guesses.each.map do |guess|
          "Zero letters in: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
        end
        text.join("\n")
      else
        'There was no guesses with zero bulls and cows matches so far.'
      end
    end

    def stop(game)
      "You give up? Here is the secret word *#{game.secret}*"
    end

    def no_permissions_to_stop_game
      'You are NOT allowed to _/stop_ this game. Only _admin_ or _creator_ is'
    end

    def help
      lines = [
          'Here is the list of available commands:',
          'Use _/create [word]|[number]_ to create a game',
          'Use _/guess <word>_ to place a guess for the secret',
          'Use _/tries_ to show previous guess attempts',
          'Use _/best [number]_ to see top guesses',
          'Use _/hint_ to reveal a random letter in a secret',
          'Use _/stop_ to abort the game and show secret'
      ]
      lines.join("\n")
    end

    def unknown_command(message)
      "Nothing I can do with *#{message}*. For help try _/help_"
    end

    def new_game?
      'Go ahead and _/create_ a new game. For help try _/help_'
    end

    private

    def no_guesses_submitted
      'There was no guesses so far. Go ahead and submit one with _/guess <word>_'
    end
  end

end
