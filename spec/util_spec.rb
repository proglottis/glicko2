require 'minitest_helper'

describe Glicko2::Util do
  describe ".ranks_to_score" do
    it "must return 1.0 when rank is less" do
      Glicko2::Util.ranks_to_score(1, 2).must_equal 1.0
    end

    it "must return 0.5 when rank is equal" do
      Glicko2::Util.ranks_to_score(1, 1).must_equal 0.5
    end

    it "must return 0.0 when rank is more" do
      Glicko2::Util.ranks_to_score(2, 1).must_equal 0.0
    end
  end
end
