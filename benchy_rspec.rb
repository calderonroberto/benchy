require 'rspec'
require './benchy.rb'


describe Benchy do
  before :each do
    #@benchy = Benchy.new("http://resttest.bench.co/transactions/")
    @benchy = Benchy.new("http://localhost/")
  end

  it "has a URI" do
    #expect(@benchy.url).to eq "http://resttest.bench.co/transactions/"
    @benchy = Benchy.new("http://localhost/")
  end

  it "has a transactions object" do
    expect(@benchy.transactions).to be_instance_of(Array)
  end

  it "should download all the transactions" do
    # There's no time to mock up this, let's run it against
    # the resttest api and assume the data is correct (38 items)
    @benchy.get_data
    expect(@benchy.transactions.length).to eq 38
  end

  it "should not ocmpute balance on empty data" do
    expect(@benchy.compute_balance).to eq(0)
  end

  it "should calculate the total balance" do
    @benchy.transactions [{"Amount"=>"-300.2"}, {"Amount"=>"300.2"}, {"Amount"=>"200.1"}]
    expect(@benchy.compute_balance).to eq 200.1
  end

  it "should calculate the total balance on bench data" do
    @benchy.get_data
    expect(@benchy.compute_balance).to eq (18377.16)
  end

  it "should clean venddor names" do
  end

  it "should not have duplicate transactions" do
  end

  it "should have a list of categories, with a list of transactions, and total expenses for that category" do
  end

  it "should have a list of daily calculated balances. (With rolling balances)" do
  end

end
