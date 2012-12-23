module Glicko2
  # Glicko ratings are calculated in bulk at the end of arbitrary, but fixed
  # length, periods named rating periods. Where a period is fixed to be long
  # enough that the average number of games that each player has played in is
  # about 5 to 10 games. It could be weekly, monthly or more as required.
  class RatingPeriod
    def initialize(players)
      @players = players.reduce({}) { |memo, player| memo[player] = []; memo }
    end

    def game(game_players, ranks)
      game_players.zip(ranks).each do |player, rank|
        game_players.zip(ranks).each do |other, other_rank|
          next if player == other
          @players[player] << [other, Util.ranks_to_score(rank, other_rank)]
        end
      end
    end

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

    def players
      @players.keys
    end

    def to_s
      "#<RatingPeriod players=#{@players.keys}"
    end
  end
end
