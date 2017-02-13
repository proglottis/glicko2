module Glicko2
  # A Rater calculates a new Rating based on actual game outcomes.
  class Rater
    attr_reader :rating

    def initialize(rating)
      @rating = rating
      @v_pre = 0.0
      @delta_pre = 0.0
    end

    # Add an outcome against the rating
    def add(other_rating, score)
      g, e = other_rating.gravity_expected_score(rating.mean)
      @v_pre += g**2 * e * (1 - e)
      @delta_pre += g * (score - e)
    end

    # Rate calculates Rating as at the start of the following period based on game outcomes
    def rate(tau)
      v = @v_pre**-1
      delta2 = (@delta_pre * v)**2
      sd2 = rating.sd**2
      a = Math.log(rating.volatility**2)
      if v.finite?
        f = lambda do |x|
          expX = Math.exp(x)
          (expX * (delta2 - sd2 - v - expX)) / (2 * (sd2 + v + expX)**2) - (x - a) / tau**2
        end
        if delta2 > sd2 + v
          b = Math.log(delta2 - sd2 - v)
        else
          k = 1
          k += 1 while f.call(a - k * tau) < 0
          b = a - k * tau
        end
        a = Util.illinois_method(a, b, &f)
      end
      volatility = Math.exp(a / 2.0)
      sd_pre = Math.sqrt(sd2 + volatility**2)
      sd = 1 / Math.sqrt(1.0 / sd_pre**2 + 1 / v)
      mean = rating.mean + sd**2 * @delta_pre
      Rating.new(mean, sd, volatility)
    end
  end
end
