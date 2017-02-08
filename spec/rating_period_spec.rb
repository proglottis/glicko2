require 'minitest_helper'

describe Glicko2::RatingPeriod do
  before do
    @player = Rating.new(1500, 200, 0.06)
    @player1 = Rating.new(1400, 30, 0.06)
    @player2 = Rating.new(1550, 100, 0.06)
    @player3 = Rating.new(1700, 300, 0.06)
    @players = [@player, @player1, @player2, @player3]
    @period = Glicko2::RatingPeriod.from_objs(@players)
  end

  describe "#initialize" do
    it "must raise if two players are identical" do
      proc {
        Glicko2::RatingPeriod.from_objs([@player, @player])
      }.must_raise Glicko2::DuplicatePlayerError
    end
  end

  describe "#generate_next" do
    it "must be close to example" do
      @period.game([@player, @player1], [1, 2])
      @period.game([@player, @player2], [2, 1])
      @period.game([@player, @player3], [2, 1])
      @period.generate_next(0.5).players.each(&:update_obj)
      obj = @player
      obj.rating.must_be_close_to 1464.06, 0.01
      obj.rating_deviation.must_be_close_to 151.52, 0.01
      obj.volatility.must_be_close_to 0.05999, 0.00001
    end

    it "must process non-competing players" do
      @period.game([@player, @player1], [1, 2])
      @period.generate_next 0.5
    end
  end
end
