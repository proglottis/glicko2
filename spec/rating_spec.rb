require 'minitest_helper'

describe Glicko2::Rating do
  before do
    @rating = Glicko2::Rating.from_glicko_rating(1500, 200)
    @rating1 = Glicko2::Rating.from_glicko_rating(1400, 30)
    @rating2 = Glicko2::Rating.from_glicko_rating(1550, 100)
    @rating3 = Glicko2::Rating.from_glicko_rating(1700, 300)
  end

  describe "#gravity_expected_score" do
    it "must be close to example 1" do
      g, e = @rating1.gravity_expected_score(@rating.mean)
      g.must_be_close_to 0.9955, 0.0001
      e.must_be_close_to 0.639, 0.001
    end

    it "must be close to example 2" do
      g, e = @rating2.gravity_expected_score(@rating.mean)
      g.must_be_close_to 0.9531, 0.0001
      e.must_be_close_to 0.432, 0.001
    end

    it "must be close to example 3" do
      g, e = @rating3.gravity_expected_score(@rating.mean)
      g.must_be_close_to 0.7242, 0.0001
      e.must_be_close_to 0.303, 0.001
    end
  end
end
