module Glicko2
  # Player maps a seed object with a Glicko2 rating.
  class Player
    attr_reader :rating, :obj

    # Create a {Player} from a seed object, converting from Glicko
    # ratings to Glicko2.
    #
    # @param [#rating,#rating_deviation,#volatility] obj seed values object
    # @return [Player] constructed instance.
    def self.from_obj(obj)
      rating = Rating.from_glicko_rating(obj.rating, obj.rating_deviation, obj.volatility)
      new(rating, obj)
    end

    def initialize(rating, obj)
      @rating = rating
      @obj = obj
    end

    # Update seed object with this player's values
    def update_obj
      mean, sd = rating.to_glicko_rating
      @obj.rating = mean
      @obj.rating_deviation = sd
      @obj.volatility = volatility
    end

    def mean
      rating.mean
    end

    def sd
      rating.sd
    end

    def volatility
      rating.volatility
    end

    def to_s
      "#<Player rating=#{rating}, obj=#{obj}>"
    end
  end
end
