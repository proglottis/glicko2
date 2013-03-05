require 'minitest_helper'

describe Glicko2::Player do
  before do
    @player = Glicko2::Player.from_obj(Rating.new(1500, 200, 0.06))
    @player1 = Glicko2::Player.from_obj(Rating.new(1400, 30, 0.06))
    @player2 = Glicko2::Player.from_obj(Rating.new(1550, 100, 0.06))
    @player3 = Glicko2::Player.from_obj(Rating.new(1700, 300, 0.06))
    @others = [@player1, @player2, @player3]
    @scores = [1, 0, 0]
  end

  describe ".from_obj" do
    it "must create player from an object as example" do
      @player.mean.must_be_close_to 0, 0.0001
      @player.sd.must_be_close_to 1.1513, 0.0001
      @player.volatility.must_equal 0.06
    end

    it "must create player from an object as example 1" do
      @player1.mean.must_be_close_to -0.5756, 0.0001
      @player1.sd.must_be_close_to 0.1727, 0.0001
      @player1.volatility.must_equal 0.06
    end

    it "must create player from an object as example 2" do
      @player2.mean.must_be_close_to 0.2878, 0.0001
      @player2.sd.must_be_close_to 0.5756, 0.0001
      @player2.volatility.must_equal 0.06
    end

    it "must create player from an object as example 3" do
      @player3.mean.must_be_close_to 1.1513, 0.0001
      @player3.sd.must_be_close_to 1.7269, 0.0001
      @player3.volatility.must_equal 0.06
    end
  end

  describe "#generate_next" do
    it "must be close to example" do
      p = @player.generate_next(@others, @scores)
      p.mean.must_be_close_to -0.2069, 0.0001
      p.sd.must_be_close_to 0.8722, 0.0001
      p.volatility.must_be_close_to 0.05999, 0.00001
    end

    it "must allow players that did not play and games" do
      p = @player.generate_next([], [])
      p.mean.must_equal @player.mean
      p.volatility.must_equal @player.volatility
      p.sd.must_be_close_to Math.sqrt(@player.sd ** 2 + @player.volatility ** 2)
    end

    it "must not decay rating deviation above default" do
      @player = Glicko2::Player.from_obj(Rating.new(1500, Glicko2::DEFAULT_GLICKO_RATING_DEVIATION, 0.06))
      p = @player.generate_next([], [])
      p.update_obj
      p.obj.rating_deviation.must_equal Glicko2::DEFAULT_GLICKO_RATING_DEVIATION
    end

    bench_performance_linear "default" do |n|
      @player.generate_next(@others * n, @scores * n)
    end
  end

  describe "#update_obj" do
    it "must update object to be close to example" do
      p = @player.generate_next(@others, @scores)
      p.update_obj
      obj = p.obj
      obj.rating.must_be_close_to 1464.06, 0.01
      obj.rating_deviation.must_be_close_to 151.52, 0.01
      obj.volatility.must_be_close_to 0.05999, 0.00001
    end
  end
end
