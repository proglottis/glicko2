module Glicko2
  class RatingPeriod
    def initialize(players)
      @players = players.reduce({}) { |memo, player| memo[player] = []; memo }
    end

    def self.ranks_to_score(rank, other)
      if rank < other
        1.0
      elsif rank == other
        0.5
      else
        0.0
      end
    end

    def game(game_players, ranks)
      game_players.zip(ranks).each do |player, rank|
        game_players.zip(ranks).each do |other, other_rank|
          next if player == other
          @players[player] << [other, self.class.ranks_to_score(rank, other_rank)]
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
