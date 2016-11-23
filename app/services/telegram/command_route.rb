module Telegram
  class Action
    BEST     = '/best'
    CREATE   = '/create'
    GUESS    = '/guess'
    HELP     = '/help'
    HINT     = '/hint'
    LANG     = '/lang'
    LEVEL    = '/level'
    START    = '/start'
    STOP     = '/stop'
    SUGGEST  = '/suggest'
    TRIES    = '/tries'
    ZERO     = '/zero'
  end

  class CommandRoute
    BOT_REGEXP = '(?:@BullsAndCowsWordsBot)?'

    BEST         = /^#{Action::BEST}#{BOT_REGEXP}$/i
    BEST_DIGIT   = /^#{Action::BEST}#{BOT_REGEXP}\s+(?<best>[[:digit:]]+)$/i
    CREATE       = /^#{Action::CREATE}#{BOT_REGEXP}$/i
    CREATE_ALPHA = /^#{Action::CREATE}#{BOT_REGEXP}\s+(?<secret>[[:alpha:]]+)$/i
    CREATE_DIGIT = /^#{Action::CREATE}#{BOT_REGEXP}\s+(?<number>[[:digit:]]+)$/i
    GUESS        = /^#{Action::GUESS}#{BOT_REGEXP}\s+(?<guess>[[:alpha:]]+)$/i
    HELP         = /^#{Action::HELP}#{BOT_REGEXP}$/i
    HINT         = /^#{Action::HINT}#{BOT_REGEXP}$/i
    HINT_ALPHA   = /^#{Action::HINT}#{BOT_REGEXP}\s+(?<letter>[[:alpha:]])$/i
    LANG         = /^#{Action::LANG}#{BOT_REGEXP}$/i
    LANG_ALPHA   = /^#{Action::LANG}#{BOT_REGEXP}\s+(?<language>[[:alpha:]]+)$/i
    LEVEL        = /^#{Action::LEVEL}#{BOT_REGEXP}$/i
    LEVEL_ALPHA  = /^#{Action::LEVEL}#{BOT_REGEXP}\s+(?<level>[[:alpha:]]+)$/i
    START        = /^#{Action::START}#{BOT_REGEXP}$/i
    STOP         = /^#{Action::STOP}#{BOT_REGEXP}$/i
    SUGGEST      = /^#{Action::SUGGEST}#{BOT_REGEXP}\s+(?<letters>[[:alpha:]]+)$/i
    TRIES        = /^#{Action::TRIES}#{BOT_REGEXP}$/i
    ZERO         = /^#{Action::ZERO}#{BOT_REGEXP}$/i
    OTHER        = /^\/.*/
  end
end


