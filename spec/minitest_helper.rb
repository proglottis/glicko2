require 'minitest/autorun'
require 'glicko2'

Rating = Struct.new(:rating, :rating_deviation, :volatility)
