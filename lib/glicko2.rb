require "glicko2/version"

module Glicko2
  TOLERANCE = 0.0000001
  DEFAULT_VOLATILITY = 0.06
  DEFAULT_GLICKO_RATING = 1500.0
  DEFAULT_GLICKO_RATING_DEVIATION = 350.0

  GLICKO_GRADIENT = 173.7178
  GLICKO_INTERCEPT = DEFAULT_GLICKO_RATING

  VOLATILITY_CHANGE = 0.5

  class Player
    attr_reader :mean, :sd, :volatility, :obj

    def self.from_obj(obj)
      mean = (obj.rating - GLICKO_INTERCEPT) / GLICKO_GRADIENT
      sd = obj.rating_deviation / GLICKO_GRADIENT
      new(mean, sd, obj.volatility, obj)
    end

    def initialize(mean, sd, volatility, obj)
      @mean = mean
      @sd = sd
      @volatility = volatility
      @obj = obj
    end

    def g
      1 / Math.sqrt(1 + 3 * sd ** 2 / Math::PI ** 2)
    end

    def e(other)
      1 / (1 + Math.exp(-other.g * (mean - other.mean)))
    end

    def variance(others)
      others.reduce(0) do |v, other|
        v + other.g ** 2 * e(other) * (1 - e(other))
      end ** -1
    end

    def delta(others, scores)
      others.zip(scores).reduce(0) do |d, (other, score)|
        d + other.g * (score - e(other))
      end * variance(others)
    end

    def f_part1(x, others, scores)
      sd_sq = sd ** 2
      v = variance(others)
      _x = Math.exp(x)
      (_x * (delta(others, scores) ** 2 - sd_sq - v - _x)) / (2 * (sd_sq + v + _x) ** 2)
    end
 
    def f_part2(x)
      (x - Math::log(volatility ** 2)) / VOLATILITY_CHANGE ** 2
    end
 
    def f(x, others, scores)
      f_part1(x, others, scores) - f_part2(x)
    end
 
    def generate_next(others, scores)
      _v = variance(others)
      a = Math::log(volatility ** 2)
      if delta(others, scores) > sd ** 2 + _v
        b = Math.log(_delta - sd ** 2 - _v)
      else
        k = 1
        k += 1 while f(a - k * VOLATILITY_CHANGE, others, scores) < 0
        b = a - k * VOLATILITY_CHANGE
      end
      fa = f(a, others, scores)
      fb = f(b, others, scores)
      while (b - a).abs > TOLERANCE
        c = a + (a - b) * fa / (fb - fa)
        fc = f(c, others, scores)
        if fc * fb < 0
          a = b
          fa = fb
        else
          fa /= 2.0
        end
        b = c
        fb = fc
      end
      o1 = Math.exp(a / 2.0)
      sd_pre = Math.sqrt(sd ** 2 + o1 ** 2)
      sd1 = 1 / Math.sqrt(1 / sd_pre ** 2 + 1 / _v)
      mean1 = mean + sd1 ** 2 * others.zip(scores).reduce(0) {|x, (other, score)| x + other.g * (score - e(other)) }
      self.class.new(mean1, sd1, o1, obj)
    end

    def update_obj
      @obj.rating = GLICKO_GRADIENT * mean + GLICKO_INTERCEPT
      @obj.rating_deviation = GLICKO_GRADIENT * sd
      @obj.volatility = volatility
    end

    def to_s
      "#<Player mean=#{mean}, sd=#{sd}, volatility=#{volatility}, obj=#{obj}>"
    end
  end

  class RatingPeriod
    def initialize(players)
      @players = players.reduce({}) { |memo, player| memo[player] = []; memo }
    end

    def self.ranks_to_score(rank, other)
      if rank < other
        1.0
      elsif rank == other
        0.5
      else
        0.0
      end
    end

    def game(game_players, ranks)
      game_players.zip(ranks).each do |player, rank|
        game_players.zip(ranks).each do |other, other_rank|
          next if player == other
          @players[player] << [other, self.class.ranks_to_score(rank, other_rank)]
        end
      end
    end

    def generate_next
      p = []
      @players.each do |player, games|
        p << player.generate_next(*games.transpose)
      end
      self.class.new(p)
    end

    def players
      @players.keys
    end

    def to_s
      "#<RatingPeriod players=#{@players.keys}"
    end
  end

end
