module Telegram
  class CommandRoute
    BOT_REGEXP = '(?:@\w+)?'

    BEST         = /^#{Telegram::Command::Action::BEST}#{BOT_REGEXP}\s*(?<best>[[:digit:]]+)?$/i
    CREATE       = /^#{Telegram::Command::Action::CREATE}#{BOT_REGEXP}$/i
    CREATE_ALPHA = /^#{Telegram::Command::Action::CREATE}#{BOT_REGEXP}\s+(?<secret>[[:alpha:]]+)$/i
    CREATE_DIGIT = /^#{Telegram::Command::Action::CREATE}#{BOT_REGEXP}\s+(?<number>[[:digit:]]+)$/i
    GUESS        = /^#{Telegram::Command::Action::GUESS}#{BOT_REGEXP}\s+(?<guess>[[:alpha:]]+)$/i
    WORD         = /\A(?<guess>[[:alpha:]]+)\z/im
    HELP         = /^#{Telegram::Command::Action::HELP}#{BOT_REGEXP}$/i
    HINT_ALPHA   = /^#{Telegram::Command::Action::HINT}#{BOT_REGEXP}\s*(?<letter>[[:alpha:]])?$/i
    HINT_DIGIT   = /^#{Telegram::Command::Action::HINT}#{BOT_REGEXP}\s+(?<number>[[:digit:]])$/i
    LANG         = /^#{Telegram::Command::Action::LANG}#{BOT_REGEXP}$/i
    LANG_ALPHA   = /^#{Telegram::Command::Action::LANG}#{BOT_REGEXP}\s+(?<language>[[:alpha:]]+)$/i
    LEVEL        = /^#{Telegram::Command::Action::LEVEL}#{BOT_REGEXP}$/i
    LEVEL_ALPHA  = /^#{Telegram::Command::Action::LEVEL}#{BOT_REGEXP}\s+(?<level>[[:alpha:]]+)$/i
    START        = /^#{Telegram::Command::Action::START}#{BOT_REGEXP}$/i
    STOP         = /^#{Telegram::Command::Action::STOP}#{BOT_REGEXP}$/i
    SUGGEST      = /^#{Telegram::Command::Action::SUGGEST}#{BOT_REGEXP}\s*(?<letters>[[:alpha:]]+)?$/i
    TRIES        = /^#{Telegram::Command::Action::TRIES}#{BOT_REGEXP}$/i
    ZERO         = /^#{Telegram::Command::Action::ZERO}#{BOT_REGEXP}$/i
    OTHER        = /^\/.*/
  end
end


