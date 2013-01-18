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
      @games = Hash.new { |h, k| h[k] = [] }
      @cache = players.reduce({}) { |memo, player| memo[player.obj] = player; memo }
    end

    # Create rating period from list of seed objects
    #
    # @param [Array<#rating,#rating_deviation,#volatility>] objs seed value objects
    # @return [RatingPeriod]
    def self.from_objs(objs, config=DEFAULT_CONFIG)
      new(objs.map { |obj| Player.from_obj(obj, config) })
    end

    # Register a game with this rating period
    #
    # @param [Array<#rating,#rating_deviation,#volatility>] game_seeds ratings participating in a game
    # @param [Array<Integer>] ranks corresponding ranks
    def game(game_seeds, ranks)
      game_seeds.zip(ranks).each do |seed, rank|
        game_seeds.zip(ranks).each do |other, other_rank|
          next if seed == other
          @games[player(seed)] << [player(other),
                                 Util.ranks_to_score(rank, other_rank)]
        end
      end
    end

    # Generate a new {RatingPeriod} with a new list of updated {Player}
    #
    # @return [RatingPeriod]
    def generate_next
      p = []
      @players.each do |player|
        games = @games[player]
        if games.length > 0
          p << player.generate_next(*games.transpose)
        else
          p << player.generate_next([], [])
        end
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
