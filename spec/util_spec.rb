require 'minitest_helper'

class TestUtil < Minitest::Test
  def test_ranks_to_score
    assert_equal 1.0, Glicko2::Util.ranks_to_score(1, 2)
    assert_equal 0.5, Glicko2::Util.ranks_to_score(1, 1)
    assert_equal 0.0, Glicko2::Util.ranks_to_score(2, 1)
  end

  def test_illinois_method
    result = Glicko2::Util.illinois_method(0.0, 1.0) do |x|
      Math.cos(x) - x ** 3
    end
    assert_in_delta 0.865474033101614, result, Glicko2::TOLERANCE
  end
end
