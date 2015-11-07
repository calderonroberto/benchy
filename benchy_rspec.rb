require 'rspec'
require './benchy.rb'


describe Benchy do
  before :each do
    @benchy = Benchy.new("http://resttest.bench.co/transactions/")
  end

  it "Has a URI" do
    expect(@benchy.get_url).to eq "http://resttest.bench.co/transactions/"
  end

end
