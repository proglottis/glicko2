module Glicko2
  # Glicko ratings are represented with a rating and rating deviation. For this
  # gem it is assumed that ratings are normally distributed where rating and
  # rating deviation correspond to mean and standard deviation.
  class NormalDistribution
    attr_reader :mean, :standard_deviation
    alias_method :sd, :standard_deviation

    def initialize(mean, standard_deviation)
      @mean = mean
      @standard_deviation = standard_deviation
    end

    # Calculate the distribution variance
    #
    # @return [Numeric]
    def variance
      standard_deviation ** 2.0
    end

    # Calculate the sum
    #
    # @param [NormalDistribution] other
    # @return [NormalDistribution]
    def +(other)
      self.class.new(mean + other.mean, Math.sqrt(variance + other.variance))
    end

    # Calculate the difference
    #
    # @param [NormalDistribution] other
    # @return [NormalDistribution]
    def -(other)
      self.class.new(mean - other.mean, Math.sqrt(variance + other.variance))
    end

    # Calculate the probability density at `x`
    #
    # @param [Numeric] x
    # @return [Numeric]
    def pdf(x)
      1.0 / (sd * Math.sqrt(2.0 * Math::PI)) *
        Math.exp(-(x - mean) ** 2.0 / 2.0 * variance)
    end

    # Calculate the cumulative distribution at `x`
    #
    # @param [Numeric] x
    # @return [Numeric]
    def cdf(x)
      0.5 * (1.0 + Math.erf((x - mean) / (sd * Math.sqrt(2.0))))
    end

    def to_s
      "#<NormalDistribution mean=#{mean}, sd=#{sd}>"
    end
  end
end
