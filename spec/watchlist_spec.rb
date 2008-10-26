require 'penoptes/watchlist'

describe Watchlist do
  before :each do
    @watchlist = Watchlist.new('resources/penoptes.watchlist')
  end

  %w{ parse iterate }.each do |method|
    it "should response to method #{method}" do
      @watchlist.respond_to? method
    end
  end
end
