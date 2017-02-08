module Glicko2
  # A Rating of a player.
  class Rating
    GLICKO_GRADIENT = 173.7178
    GLICKO_INTERCEPT = DEFAULT_GLICKO_RATING

    attr_reader :mean, :sd, :volatility

    def initialize(mean, sd, volatility=nil)
      @mean = mean
      @sd = sd
      @volatility = volatility || DEFAULT_VOLATILITY
    end

    # Creates a Rating from the Glicko scale.
    def self.from_glicko_rating(r, rd, volatility=nil)
      new((r - GLICKO_INTERCEPT) / GLICKO_GRADIENT, rd / GLICKO_GRADIENT, volatility)
    end

    # Converts to the Glicko scale.
    def to_glicko_rating
      [GLICKO_GRADIENT * mean + GLICKO_INTERCEPT, GLICKO_GRADIENT * sd]
    end

    # Calculate `g(phi)` and `E(mu, mu_j, phi_j)` as defined in the Glicko2 paper
    def gravity_expected_score(other_mean)
      g = 1 / Math.sqrt(1 + 3 * sd**2 / Math::PI**2)
      [g, 1 / (1 + Math.exp(-g * (other_mean - mean)))]
    end

    def to_s
      "#<Rating mean=#{mean}, sd=#{sd}, volatility=#{volatility}>"
    end
  end
end
