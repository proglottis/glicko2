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
    attr_reader :rating, :obj

    # Create a {Player} from a seed object, converting from Glicko
    # ratings to Glicko2.
    #
    # @param [#rating,#rating_deviation,#volatility] obj seed values object
    # @return [Player] constructed instance.
    def self.from_obj(obj, config=nil)
      rating = Rating.from_glicko_rating(obj.rating, obj.rating_deviation,
                                         obj.volatility, config)
      new(rating, obj)
    end

    # @param [Numeric] mean player mean
    # @param [Numeric] sd player standard deviation
    # @param [Numeric] volatility player volatility
    # @param [#rating,#rating_deviation,#volatility] obj seed values object
    def initialize(rating, obj=nil)
      @rating = rating
      @obj = obj
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
        others = others.map{ |other| other.rating }
        generate_next_with_games(others, scores)
      end
    end

    # Update seed object with this player's values
    def update_obj
      glicko_rating = rating.to_glicko_rating
      @obj.rating = glicko_rating.mean
      @obj.rating_deviation = glicko_rating.standard_deviation
      @obj.volatility = volatility
    end

    def mean
      rating.mean
    end

    def standard_deviation
      rating.standard_deviation
    end
    alias_method :sd, :standard_deviation

    def volatility
      rating.volatility
    end

    def to_s
      "#<Player rating=#{rating}, obj=#{obj}>"
    end

    private

    def generate_next_without_games
      next_rating = Rating.new(mean, rating.standard_deviation_pre,
                               volatility, rating.config)
      self.class.new(next_rating, obj)
    end

    def generate_next_with_games(others, scores)
      rating = generate_next_rating(others, scores)
      self.class.new(rating, obj)
    end

    def generate_next_rating(others, scores)
      _v = rating.estimated_variance(others)
      _volatility = rating.next_volatility(others, scores, _v)
      _sd = rating.next_standard_deviation(_v)
      _mean = rating.next_mean(others, scores, _sd)
      Rating.new(_mean, _sd, _volatility, rating.config)
    end
  end
end
