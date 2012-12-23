require "glicko2/version"
require "glicko2/player"
require "glicko2/rating_period"

module Glicko2
  DEFAULT_VOLATILITY = 0.06
  DEFAULT_GLICKO_RATING = 1500.0
  DEFAULT_GLICKO_RATING_DEVIATION = 350.0

  VOLATILITY_CHANGE = 0.5

  # Collection of helper methods
  class Util
    GLICKO_GRADIENT = 173.7178
    GLICKO_INTERCEPT = DEFAULT_GLICKO_RATING

    # Convert from the original Glicko scale to Glicko2 scale
    #
    # @param [Numeric] r Glicko rating
    # @param [Numeric] rd Glicko rating deviation
    # @return [Array<Numeric>]
    def self.to_glicko2(r, rd)
      [(r - GLICKO_INTERCEPT) / GLICKO_GRADIENT, rd / GLICKO_GRADIENT]
    end

    # Convert from the Glicko2 scale to the original Glicko scale
    #
    # @param [Numeric] m Glicko2 mean
    # @param [Numeric] sd Glicko2 standard deviation
    # @return [Array<Numeric>]
    def self.to_glicko(m, sd)
      [GLICKO_GRADIENT * m + GLICKO_INTERCEPT, GLICKO_GRADIENT * sd]
    end
  end
end
