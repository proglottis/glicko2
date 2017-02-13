module Glicko2
  # Glicko ratings are calculated in bulk at the end of arbitrary, but fixed
  # length, periods named rating periods. Where a period is fixed to be long
  # enough that the average number of games that each player has played in is
  # about 5 to 10 games. It could be weekly, monthly or more as required.
  class RatingPeriod
    attr_reader :players

    # @param [Array<Player>] players
    def initialize(players)
      @players = players
      @cache = players.reduce({}) do |memo, player|
        raise DuplicatePlayerError unless memo[player.obj].nil?
        memo[player.obj] = player
        memo
      end
      @raters = players.reduce({}) do |memo, player|
        memo[player.obj] = Rater.new(player.rating)
        memo
      end
    end

    # Create rating period from list of seed objects
    #
    # @param [Array<#rating,#rating_deviation,#volatility>] objs seed value objects
    # @return [RatingPeriod]
    def self.from_objs(objs)
      new(objs.map { |obj| Player.from_obj(obj) })
    end

    # Register a game with this rating period
    #
    # @param [Array<#rating,#rating_deviation,#volatility>] game_seeds ratings participating in a game
    # @param [Array<Integer>] ranks corresponding ranks
    def game(game_seeds, ranks)
      game_seeds.each_with_index do |iseed, i|
        game_seeds.each_with_index do |jseed, j|
          next if i == j
          @raters[iseed].add(player(jseed).rating, Util.ranks_to_score(ranks[i], ranks[j]))
        end
      end
    end

    # Generate a new {RatingPeriod} with a new list of updated {Player}
    #
    # @return [RatingPeriod]
    def generate_next(tau)
      p = []
      @players.each do |player|
        p << Player.new(@raters[player.obj].rate(tau), player.obj)
      end
      self.class.new(p)
    end

    # Fetch the player associated with a seed object
    #
    # @param [#rating,#rating_deviation,#volatility] obj seed object
    # @return [Player]
    def player(obj)
      @cache[obj]
    end

    def to_s
      "#<RatingPeriod players=#{@players}"
    end
  end
end
