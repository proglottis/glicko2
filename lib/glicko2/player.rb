module Glicko2
  # Calculates a new Glicko2 ranking based on a seed object and game outcomes.
  #
  # The example from the Glicko2 paper, where a player wins against the first
  # opponent, but then looses against the next two:
  #
  #   Rating = Struct.new(:rating, :rating_deviation, :volatility)
  #
  #   player_seed = Rating.new(1500, 200, 0.06)
  #   opponent1_seed = Rating.new(1400, 30, 0.06)
  #   opponent2_seed = Rating.new(1550, 100, 0.06)
  #   opponent3_seed = Rating.new(1700, 300, 0.06)
  #
  #   player = Glicko2::Player.from_obj(player_seed)
  #   opponent1 = Glicko2::Player.from_obj(opponent1_seed)
  #   opponent2 = Glicko2::Player.from_obj(opponent2_seed)
  #   opponent3 = Glicko2::Player.from_obj(opponent3_seed)
  #
  #   new_player = player.generate_next([opponent1, opponent2, opponent3],
  #                                     [1, 0, 0])
  #   new_player.update_obj
  #
  #   puts player_seed
  #
  class Player
    TOLERANCE = 0.0000001

    attr_reader :mean, :sd, :volatility, :obj

    # Create a {Player} from a seed object, converting from Glicko
    # ratings to Glicko2.
    #
    # @param [#rating,#rating_deviation,#volatility] obj seed values object
    # @return [Player] constructed instance.
    def self.from_obj(obj)
      mean, sd = Util::to_glicko2(obj.rating, obj.rating_deviation)
      new(mean, sd, obj.volatility, obj)
    end

    # @param [Numeric] mean player mean
    # @param [Numeric] sd player standard deviation
    # @param [Numeric] volatility player volatility
    # @param [#rating,#rating_deviation,#volatility] obj seed values object
    def initialize(mean, sd, volatility, obj=nil)
      @mean = mean
      @sd = sd
      @volatility = volatility
      @obj = obj
      @e = {}
    end

    # Calculate `g(phi)` as defined in the Glicko2 paper
    #
    # @return [Numeric]
    def g
      @g ||= 1 / Math.sqrt(1 + 3 * sd ** 2 / Math::PI ** 2)
    end

    # Calculate `E(mu, mu_j, phi_j)` as defined in the Glicko2 paper
    #
    # @param [Player] other the `j` player
    # @return [Numeric]
    def e(other)
      @e[other] ||= 1 / (1 + Math.exp(-other.g * (mean - other.mean)))
    end

    # Calculate the estimated variance of the team's/player's rating based only
    # on the game outcomes.
    #
    # @param [Array<Player>] others other participating players.
    # @return [Numeric]
    def variance(others)
      return 0.0 if others.length < 1
      others.reduce(0) do |v, other|
        e_other = e(other)
        v + other.g ** 2 * e_other * (1 - e_other)
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
        d + other.g * (score - e(other))
      end * variance(others)
    end

    # Calculate `f(x)` as defined in the Glicko2 paper
    #
    # @param [Numeric] x
    # @param [Numeric] d the result of calculating {#delta}
    # @param [Numeric] v the result of calculating {#variance}
    # @return [Numeric]
    def f(x, d, v)
      f_part1(x, d, v) - f_part2(x)
    end

    # Calculate the new value of the volatility
    #
    # @param [Numeric] d the result of calculating {#delta}
    # @param [Numeric] v the result of calculating {#variance}
    # @return [Numeric]
    def volatility1(d, v)
      a = Math::log(volatility ** 2)
      if d > sd ** 2 + v
        b = Math.log(d - sd ** 2 - v)
      else
        k = 1
        k += 1 while f(a - k * VOLATILITY_CHANGE, d, v) < 0
        b = a - k * VOLATILITY_CHANGE
      end
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

    # Create new {Player} with updated values.
    #
    # This method will not modify any objects that are passed into it.
    #
    # @param [Array<Player>] others list of opponent players
    # @param [Array<Numeric>] scores list of correlating scores (`0` for a loss,
    #   `0.5` for a draw and `1` for a win).
    # @return [Player]
    def generate_next(others, scores)
      if others.length < 1
        generate_next_without_games
      else
        generate_next_with_games(others, scores)
      end
    end

    # Update seed object with this player's values
    def update_obj
      @obj.rating, @obj.rating_deviation = Util::to_glicko(mean, sd)
      @obj.volatility = volatility
    end

    def to_s
      "#<Player mean=#{mean}, sd=#{sd}, volatility=#{volatility}, obj=#{obj}>"
    end

    private

    def generate_next_without_games
      sd_pre = Math.sqrt(sd ** 2 + volatility ** 2)
      self.class.new(mean, sd_pre, volatility, obj)
    end

    def generate_next_with_games(others, scores)
      _v = variance(others)
      _d = delta(others, scores)
      _volatility = volatility1(_d, _v)
      sd_pre = Math.sqrt(sd ** 2 + _volatility ** 2)
      _sd = 1 / Math.sqrt(1 / sd_pre ** 2 + 1 / _v)
      _mean = mean + _sd ** 2 * others.zip(scores).reduce(0) {
        |x, (other, score)| x + other.g * (score - e(other))
      }
      self.class.new(_mean, _sd, _volatility, obj)
    end

    def f_part1(x, d, v)
      exp_x = Math.exp(x)
      sd_sq = sd ** 2
      (exp_x * (d ** 2 - sd_sq - v - exp_x)) / (2 * (sd_sq + v + exp_x) ** 2)
    end

    def f_part2(x)
      (x - Math::log(volatility ** 2)) / VOLATILITY_CHANGE ** 2
    end
  end
end
