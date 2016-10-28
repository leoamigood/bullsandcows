module Responses
  class Hint < Response

    def initialize(hint, match)
      @letter = !!hint ? hint : match
      @match = match.present?
    end

  end
end
