module Glicko2
  class Rating < NormalDistribution
    GLICKO_GRADIENT = 173.7178
    GLICKO_INTERCEPT = DEFAULT_GLICKO_RATING
    MIN_SD = DEFAULT_GLICKO_RATING_DEVIATION / GLICKO_GRADIENT
    TOLERANCE = 0.0000001

    attr_reader :volatility, :config

    def initialize(mean, sd, volatility=nil, config=nil)
      super(mean, sd)
      @volatility = volatility || DEFAULT_VOLATILITY
      @config = config || DEFAULT_CONFIG
      @e = {}
    end

    def self.from_glicko_rating(r, rd, volatility=nil, config=nil)
      new((r - GLICKO_INTERCEPT) / GLICKO_GRADIENT, rd / GLICKO_GRADIENT,
          volatility, config)
    end

    def to_glicko_rating
      NormalDistribution.new(GLICKO_GRADIENT * mean + GLICKO_INTERCEPT,
                             GLICKO_GRADIENT * sd)
    end

    # Calculate `g(phi)` as defined in the Glicko2 paper
    #
    # @return [Numeric]
    def gravity
      @gravity ||= 1 / Math.sqrt(1 + 3 * variance / Math::PI ** 2)
    end

    # Calculate `E(mu, mu_j, phi_j)` as defined in the Glicko2 paper
    #
    # @param [Player] other the `j` player
    # @return [Numeric]
    def expected_fractional_score(other)
      @e[other] ||= 1 / (1 + Math.exp(-other.gravity * (mean - other.mean)))
    end

    # Calculate the estimated variance of the team's/player's rating based only
    # on the game outcomes.
    #
    # @param [Array<Player>] others other participating players.
    # @return [Numeric]
    def estimated_variance(others)
      return 0.0 if others.length < 1
      others.reduce(0) do |v, other|
        e_other = expected_fractional_score(other)
        v + other.gravity ** 2 * e_other * (1 - e_other)
      end ** -1
    end

    # Calculate the estimated improvement in rating by comparing the
    # pre-period rating to the performance rating based only on game outcomes.
    #
    # @param [Array<Player>] others list of opponent players
    # @param [Array<Numeric>] scores list of correlating scores (`0` for a loss,
    #   `0.5` for a draw and `1` for a win).
    # @return [Numeric]
    def delta(others, scores)
      others.zip(scores).reduce(0) do |d, (other, score)|
        d + other.gravity * (score - expected_fractional_score(other))
      end * estimated_variance(others)
    end

    # Calculate `f(x)` as defined in the Glicko2 paper
    #
    # @param [Numeric] x
    # @param [Numeric] d the result of calculating {#delta}
    # @param [Numeric] v the result of calculating {#estimated_variance}
    # @return [Numeric]
    def f(x, d, v)
      f_part1(x, d, v) - f_part2(x)
    end

    # Calculate the pre-game standard deviation
    #
    # This slightly increases the standard deviation in case the player has
    # been stagnant for a rating period.
    def standard_deviation_pre
      [Math.sqrt(variance + volatility ** 2), MIN_SD].min
    end

    # Calculate the new value of the volatility
    #
    # @param [Numeric] d the result of calculating {#delta}
    # @param [Numeric] v the result of calculating {#estimated_variance}
    # @return [Numeric]
    def next_volatility(others, scores, v)
      d, a, b = next_volatility_setup(others, scores, v)
      fa = f(a, d, v)
      fb = f(b, d, v)
      while (b - a).abs > TOLERANCE
        c = a + (a - b) * fa / (fb - fa)
        fc = f(c, d, v)
        if fc * fb < 0
          a = b
          fa = fb
        else
          fa /= 2.0
        end
        b = c
        fb = fc
      end
      Math.exp(a / 2.0)
    end

    def next_standard_deviation(v)
      1 / Math.sqrt(1 / standard_deviation_pre ** 2 + 1 / v)
    end

    def next_mean(others, scores, next_sd)
      others.zip(scores).reduce(0) { |x, (other, score)|
        x + other.gravity * (score - expected_fractional_score(other))
      } * next_sd ** 2.0 + mean
    end

    def to_s
      "#<Rating mean=#{mean}, sd=#{sd}, volatility=#{volatility}>"
    end

    private

    def f_part1(x, d, v)
      exp_x = Math.exp(x)
      sd_sq = variance
      (exp_x * (d ** 2 - sd_sq - v - exp_x)) / (2 * (sd_sq + v + exp_x) ** 2)
    end

    def f_part2(x)
      (x - Math::log(volatility ** 2)) / config[:volatility_change] ** 2
    end

    def next_volatility_setup(others, scores, v)
      d = delta(others, scores)
      a = Math::log(volatility ** 2)
      if d > variance + v
        b = Math.log(d - variance - v)
      else
        k = 1
        k += 1 while f(a - k * config[:volatility_change], d, v) < 0
        b = a - k * config[:volatility_change]
      end
      [d, a, b]
    end

  end
end
