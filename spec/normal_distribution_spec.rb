require 'minitest_helper'

describe Glicko2::NormalDistribution do
  describe "#variance" do
    it "must return the square of the standard deviation" do
      Glicko2::NormalDistribution.new(1.0, 1.0).variance.must_equal 1.0 ** 2.0
      Glicko2::NormalDistribution.new(1.0, 2.0).variance.must_equal 2.0 ** 2.0
      Glicko2::NormalDistribution.new(1.0, 10.0).variance.must_equal 10.0 ** 2.0
    end
  end

  describe "#+" do
    let(:dist1) { Glicko2::NormalDistribution.new(10.0, 0.5) }
    let(:dist2) { Glicko2::NormalDistribution.new(5.0, 1.0) }

    it "must sum the means" do
      (dist1 + dist2).mean.must_equal 15.0
    end

    it "must sqrt the sum of the variances" do
      (dist1 + dist2).sd.must_equal Math.sqrt(0.5 ** 2.0 + 1.0 ** 2.0)
    end
  end

  describe "#-" do
    let(:dist1) { Glicko2::NormalDistribution.new(10.0, 0.5) }
    let(:dist2) { Glicko2::NormalDistribution.new(5.0, 1.0) }

    it "must subtract the means" do
      (dist1 - dist2).mean.must_equal 5.0
    end

    it "must sqrt the sum of the variances" do
      (dist1 - dist2).sd.must_equal Math.sqrt(0.5 ** 2.0 + 1.0 ** 2.0)
    end
  end

  describe "#pdf" do
    describe "standard normal" do
      let(:dist) { Glicko2::NormalDistribution.new(0.0, 1.0) }

      it "must calculate PDF at x" do
        dist.pdf(-5.0).must_be_close_to 0.00000149, 0.00000001
        dist.pdf(-2.5).must_be_close_to 0.01752830, 0.00000001
        dist.pdf(-1.0).must_be_close_to 0.24197072, 0.00000001
        dist.pdf(0.0).must_be_close_to 0.39894228, 0.00000001
        dist.pdf(1.0).must_be_close_to 0.24197072, 0.00000001
        dist.pdf(2.5).must_be_close_to 0.01752830, 0.00000001
        dist.pdf(5.0).must_be_close_to 0.00000149, 0.00000001
      end
    end
  end

  describe "#cdf" do
    describe "standard normal" do
      let(:dist) { Glicko2::NormalDistribution.new(0.0, 1.0) }

      it "must calculate CDF at x" do
        dist.cdf(-5.0).must_be_close_to 0.00000029, 0.00000001
        dist.cdf(-2.5).must_be_close_to 0.00620967, 0.00000001
        dist.cdf(-1.0).must_be_close_to 0.15865525, 0.00000001
        dist.cdf(0.0).must_be_close_to 0.50000000, 0.00000001
        dist.cdf(1.0).must_be_close_to 0.84134475, 0.00000001
        dist.cdf(2.5).must_be_close_to 0.99379033, 0.00000001
        dist.cdf(5.0).must_be_close_to 0.99999971, 0.00000001
      end
    end
  end

  describe "#<=>" do
    let(:dist1) { Glicko2::NormalDistribution.new(10.0, 0.5) }
    let(:dist2) { Glicko2::NormalDistribution.new(5.0, 1.0) }

    it "must compare the same mean" do
      (dist1 <=> dist1).must_equal 0
      (dist2 <=> dist2).must_equal 0
    end

    it "must compare against smaller mean" do
      (dist1 <=> dist2).must_equal 1
    end

    it "must compare against larger mean" do
      (dist2 <=> dist1).must_equal(-1)
    end

    describe "Comparable" do
      it "must compare" do
        (dist1 == dist1).must_equal true
        (dist2 == dist2).must_equal true
        (dist1 > dist2).must_equal true
        (dist1 < dist2).must_equal false
        (dist2 > dist1).must_equal false
        (dist2 < dist1).must_equal true
      end
    end
  end
end
