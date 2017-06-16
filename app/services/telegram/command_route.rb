module Telegram
  class CommandRoute
    BOT_REGEXP = '(?:@\w+)?'

    BEST         = /^#{Telegram::Action::Command::BEST}#{BOT_REGEXP}\s*(?<best>[[:digit:]]+)?$/i
    CREATE       = /^#{Telegram::Action::Command::CREATE}#{BOT_REGEXP}$/i
    CREATE_ALPHA = /^#{Telegram::Action::Command::CREATE}#{BOT_REGEXP}\s+(?<secret>[[:alpha:]]+)$/i
    CREATE_DIGIT = /^#{Telegram::Action::Command::CREATE}#{BOT_REGEXP}\s+(?<number>[[:digit:]]+)$/i
    FAQ          = /^#{Telegram::Action::Command::FAQ}#{BOT_REGEXP}$/i
    GUESS        = /^#{Telegram::Action::Command::GUESS}#{BOT_REGEXP}\s+(?<guess>[[:alpha:]]+)$/i
    WORD         = /\A(?<guess>[[:alpha:]]+)\z/im
    HELP         = /^#{Telegram::Action::Command::HELP}#{BOT_REGEXP}$/i
    HINT_ALPHA   = /^#{Telegram::Action::Command::HINT}#{BOT_REGEXP}\s*(?<letter>[[:alpha:]])?$/i
    HINT_DIGIT   = /^#{Telegram::Action::Command::HINT}#{BOT_REGEXP}\s+(?<number>[[:digit:]]+)$/i
    LANG         = /^#{Telegram::Action::Command::LANG}#{BOT_REGEXP}$/i
    LANG_ALPHA   = /^#{Telegram::Action::Command::LANG}#{BOT_REGEXP}\s+(?<language>[[:alpha:]]+)$/i
    LEVEL        = /^#{Telegram::Action::Command::LEVEL}#{BOT_REGEXP}$/i
    LEVEL_ALPHA  = /^#{Telegram::Action::Command::LEVEL}#{BOT_REGEXP}\s+(?<level>[[:alpha:]]+)$/i
    RULES        = /^#{Telegram::Action::Command::RULES}#{BOT_REGEXP}/i
    SCORE        = /^#{Telegram::Action::Command::SCORE}#{BOT_REGEXP}\s*(?<period>[[:digit:]]+)?$/i
    START        = /^#{Telegram::Action::Command::START}#{BOT_REGEXP}\s*(?<prologue>(howto))?$/i
    STOP         = /^#{Telegram::Action::Command::STOP}#{BOT_REGEXP}$/i
    SUGGEST      = /^#{Telegram::Action::Command::SUGGEST}#{BOT_REGEXP}\s*(?<letters>[[:alpha:]]+)?$/i
    TREND        = /^#{Telegram::Action::Command::TREND}#{BOT_REGEXP}\s*(?<since>(day|week|month))?$/i
    TRIES        = /^#{Telegram::Action::Command::TRIES}#{BOT_REGEXP}$/i
    ZERO         = /^#{Telegram::Action::Command::ZERO}#{BOT_REGEXP}$/i
    OTHER        = /^\/.*/
  end
end


