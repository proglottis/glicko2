require 'minitest_helper'

describe Glicko2::Rating do
  before do
    @rating = Glicko2::Rating.from_glicko_rating(1500, 200)
    @rating1 = Glicko2::Rating.from_glicko_rating(1400, 30)
    @rating2 = Glicko2::Rating.from_glicko_rating(1550, 100)
    @rating3 = Glicko2::Rating.from_glicko_rating(1700, 300)
    @others = [@rating1, @rating2, @rating3]
    @scores = [1, 0, 0]
  end

  describe "#gravity" do
    it "must be close to example 1" do
      @rating1.gravity.must_be_close_to 0.9955, 0.0001
    end

    it "must be close to example 2" do
      @rating2.gravity.must_be_close_to 0.9531, 0.0001
    end

    it "must be close to example 3" do
      @rating3.gravity.must_be_close_to 0.7242, 0.0001
    end
  end

  describe "#expected_fractional_score" do
    it "must be close to example 1" do
      @rating.expected_fractional_score(@rating1).must_be_close_to 0.639
    end

    it "must be close to example 2" do
      @rating.expected_fractional_score(@rating2).must_be_close_to 0.432
    end

    it "must be close to example 3" do
      @rating.expected_fractional_score(@rating3).must_be_close_to 0.303
    end
  end

  describe "#estimated_variance" do
    it "must be close to example" do
      @rating.estimated_variance(@others).must_be_close_to 1.7785
    end
  end

  describe "#delta" do
    it "must be close to example" do
      @rating.delta(@others, @scores).must_be_close_to -0.4834
    end
  end

end
