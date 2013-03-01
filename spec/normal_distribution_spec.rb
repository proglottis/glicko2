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
end
