module Glicko2
  class NormalDistribution
    attr_reader :mean, :standard_deviation
    alias_method :sd, :standard_deviation

    def initialize(mean, standard_deviation)
      @mean = mean
      @standard_deviation = standard_deviation
    end

    def variance
      standard_deviation ** 2.0
    end

    def +(other)
      self.class.new(mean + other.mean, Math.sqrt(variance + other.variance))
    end

    def -(other)
      self.class.new(mean - other.mean, Math.sqrt(variance + other.variance))
    end

    def to_s
      "#<NormalDistribution mean=#{mean}, sd=#{sd}>"
    end
  end
end
