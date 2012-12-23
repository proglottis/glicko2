module Glicko2
  # Glicko ratings are calculated in bulk at the end of arbitrary, but fixed
  # length, periods named rating periods. Where a period is fixed to be long
  # enough that the average number of games that each player has played in is
  # about 5 to 10 games. It could be weekly, monthly or more as required.
  class RatingPeriod
    # @param [Array<Player>] players
    def initialize(players)
      @players = players.reduce({}) do |memo, player|
        memo[player] = []
        memo
      end
      @seeds = players.reduce({}) do |memo, player|
        memo[player.obj] = player
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
      game_seeds.zip(ranks).each do |seed, rank|
        game_seeds.zip(ranks).each do |other, other_rank|
          next if seed == other
          @players[@seeds[seed]] << [@seeds[other],
                                     Util.ranks_to_score(rank, other_rank)]
        end
      end
    end

    # Generate a new {RatingPeriod} with a new list of updated {Player}
    #
    # @return [RatingPeriod]
    def generate_next
      p = []
      @players.each do |player, games|
        if games.length > 0
          p << player.generate_next(*games.transpose)
        else
          p << player.generate_next([], [])
        end
      end
      self.class.new(p)
    end

    # @return [Array<Player>]
    def players
      @players.keys
    end

    def to_s
      "#<RatingPeriod players=#{@players.keys}"
    end
  end
end
