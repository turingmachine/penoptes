require 'penoptes/configuration'

describe Configuration do
  before :each do
    @configuration = Configuration.new('resources/penoptes.conf')
  end

  %w{ id watchlist }.each do |method|
    it "should response to method #{method}" do
      @configuration.respond_to? method
    end
  end
end
