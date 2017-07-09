module Facebook
  class CommandRoute
    BEST         = /^#{Telegram::Action::Command::BEST}\s*(?<best>[[:digit:]]+)?$/i
    CREATE       = /^#{Telegram::Action::Command::CREATE}$/i
    CREATE_ALPHA = /^#{Telegram::Action::Command::CREATE}\s+(?<secret>[[:alpha:]]+)$/i
    CREATE_DIGIT = /^#{Telegram::Action::Command::CREATE}\s+(?<number>[[:digit:]]+)$/i
    GUESS        = /^#{Telegram::Action::Command::GUESS}\s+(?<guess>[[:alpha:]]+)$/i
    WORD         = /\A(?<guess>[[:alpha:]]+)\z/im
    HELP         = /^#{Telegram::Action::Command::HELP}$/i
    HINT_ALPHA   = /^#{Telegram::Action::Command::HINT}\s*(?<letter>[[:alpha:]])?$/i
    HINT_DIGIT   = /^#{Telegram::Action::Command::HINT}\s+(?<number>[[:digit:]]+)$/i
    LANG         = /^#{Telegram::Action::Command::LANG}$/i
    LANG_ALPHA   = /^#{Telegram::Action::Command::LANG}\s+(?<language>[[:alpha:]]+)$/i
    LEVEL        = /^#{Telegram::Action::Command::LEVEL}$/i
    LEVEL_ALPHA  = /^#{Telegram::Action::Command::LEVEL}\s+(?<level>[[:alpha:]]+)$/i
    RULES        = /^#{Telegram::Action::Command::RULES}/i
    SCORE        = /^#{Telegram::Action::Command::SCORE}\s*(?<period>[[:digit:]]+)?$/i
    START        = /^#{Telegram::Action::Command::START}\s*(?<prologue>(howto))?$/i
    STOP         = /^#{Telegram::Action::Command::STOP}$/i
    SUGGEST      = /^#{Telegram::Action::Command::SUGGEST}\s*(?<letters>[[:alpha:]]+)?$/i
    TREND        = /^#{Telegram::Action::Command::TREND}\s*(?<since>(day|week|month))?$/i
    TRIES        = /^#{Telegram::Action::Command::TRIES}$/i
    ZERO         = /^#{Telegram::Action::Command::ZERO}$/i
    OTHER        = /^\/.*/
  end
end


