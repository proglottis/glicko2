# Glicko2

Implementation of Glicko2 ratings.

Based on Mark Glickman's paper http://www.glicko.net/glicko/glicko2.pdf

## Installation

Add this line to your application's Gemfile:

    gem 'glicko2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install glicko2

## Usage

```ruby
require 'glicko2'

# Objects to store Glicko ratings
Rating = Struct.new(:rating, :rating_deviation, :volatility)
rating1 = Rating.new(1400, 30, 0.06)
rating2 = Rating.new(1550, 100, 0.06)

# Rating period with all participating ratings
period = Glicko2::RatingPeriod.from_objs [rating1, rating2]

# Register a game where rating1 wins against rating2
period.game([rating1, rating2], [1,2])

# Generate the next rating period with updated players
next_period = period.generate_next(0.5)

# Update all Glicko ratings
next_period.players.each { |p| p.update_obj }

# Output updated Glicko ratings
puts rating1
puts rating2
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
