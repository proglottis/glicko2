require 'minitest_helper'

describe Glicko2::NormalDistribution do
  describe "#variance" do
    it "must return the square of the standard deviation" do
      Glicko2::NormalDistribution.new(1.0, 1.0).variance.must_equal 1.0 ** 2.0
      Glicko2::NormalDistribution.new(1.0, 2.0).variance.must_equal 2.0 ** 2.0
      Glicko2::NormalDistribution.new(1.0, 10.0).variance.must_equal 10.0 ** 2.0
    end
  end
end
