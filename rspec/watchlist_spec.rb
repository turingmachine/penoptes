require 'penoptes/watchlist'

describe Watchlist do
  before :each do
    @watchlist = Watchlist.new('resources/penoptes.conf')
  end
end
