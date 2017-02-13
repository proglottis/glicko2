require 'bigdecimal'
require 'minitest_helper'

class TestRater < Minitest::Test
  def setup
    @rating = Glicko2::Rating.from_glicko_rating(1500, 200)
    @rating1 = Glicko2::Rating.from_glicko_rating(1400, 30)
    @rating2 = Glicko2::Rating.from_glicko_rating(1550, 100)
    @rating3 = Glicko2::Rating.from_glicko_rating(1700, 300)
  end

  def test_rate_matches_example
    rater = Glicko2::Rater.new(@rating)
    rater.add(@rating1, 1.0)
    rater.add(@rating2, 0.0)
    rater.add(@rating3, 0.0)
    rating = rater.rate(0.5)

    assert_in_delta(-0.2069, rating.mean, 0.00005)
    assert_in_delta(0.8722, rating.sd, 0.00005)
    assert_in_delta(0.05999, rating.volatility, 0.00005)
  end

  def test_rate_no_games
    rating = Glicko2::Rater.new(@rating).rate(0.5)

    assert_in_delta(@rating.mean, rating.mean, 0.00005)
    assert_in_delta(Math.sqrt(@rating.sd**2 + @rating.volatility**2), rating.sd, 0.00005)
    assert_in_delta(Glicko2::DEFAULT_VOLATILITY, rating.volatility, 0.00005)
  end

  def test_rate_no_games_big_decimal
    @rating = Glicko2::Rating.from_glicko_rating(BigDecimal.new(1500), BigDecimal.new(200))
    rating = Glicko2::Rater.new(@rating).rate(0.5)

    assert_in_delta(@rating.mean, rating.mean, 0.00005)
    assert_in_delta(Math.sqrt(@rating.sd**2 + @rating.volatility**2), rating.sd, 0.00005)
    assert_in_delta(Glicko2::DEFAULT_VOLATILITY, rating.volatility, 0.00005)
  end
end
