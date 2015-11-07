require 'rspec'
require './benchy.rb'

describe Benchy do
  before :each do
    #@benchy = Benchy.new("http://resttest.bench.co/transactions/")
    @benchy = Benchy.new("http://localhost/") # local testing
  end

  it "has a URI" do
    expect(@benchy.url).to eq "http://resttest.bench.co/transactions/"
  end

  it "has a transactions object" do
    expect(@benchy.transactions).to be_instance_of Array
  end

  it "should download all the transactions" do
    # There's no time to mock up this, let's run it against
    # the resttest api and assume the data is correct (38 items)
    @benchy.get_data
    expect(@benchy.transactions.length).to eq 36 #
  end

  it "should not ocmpute balance on empty data" do
    expect(@benchy.compute_balance).to eq 0.0
  end

  it "should calculate the total balance" do
    @benchy.transactions [{:Amount => -300.2}, {:Amount => 300.2}, {:Amount => 200.1}]
    expect(@benchy.compute_balance).to eq 200.1
  end

  it "should calculate the total balance on bench data" do
    @benchy.get_data
    expect(@benchy.compute_balance).to eq 20262.81
  end

  it "should clean vendor names" do
    [{"Company"=>"NESTERS MARKET #x0064 VANCOUVER BC"}, {"Company"=>"DROPBOX xxxxxx8396 CA 9.99 USD @ xx1001"}, {"Company"=>"COMMODORE LANES & BILL VANCOUVER BC"}].each do |t|
       @benchy.add_transaction t
    end
    expect(@benchy.transactions).to eq [{:Date=>nil, :Ledger=>"Unknown", :Company=>"NESTERS MARKET VANCOUVER BC", :Amount=>0.0}, {:Date=>nil, :Ledger=>"Unknown", :Company=>"DROPBOX", :Amount=>0.0}, {:Date=>nil, :Ledger=>"Unknown", :Company=>"COMMODORE LANES & BILL VANCOUVER BC", :Amount=>0.0}]
  end

  it "should not have duplicate transactions" do
    [{"Company"=>"NESTERS MARKET #x0064 VANCOUVER BC"}, {"Company"=>"DROPBOX xxxxxx8396 CA 9.99 USD @ xx1001"}, {"Company"=>"COMMODORE LANES & BILL VANCOUVER BC"}, {"Company"=>"COMMODORE LANES & BILL VANCOUVER BC"}].each do |t|
       @benchy.add_transaction t
    end
    expect(@benchy.transactions).to eq [{:Date=>nil, :Ledger=>"Unknown", :Company=>"NESTERS MARKET VANCOUVER BC", :Amount=>0.0}, {:Date=>nil, :Ledger=>"Unknown", :Company=>"DROPBOX", :Amount=>0.0}, {:Date=>nil, :Ledger=>"Unknown", :Company=>"COMMODORE LANES & BILL VANCOUVER BC", :Amount=>0.0}]
  end

  it "should have a list of categories, with a list of transactions, and total expenses for that category" do

    [{"Date"=>"2013-12-13", "Ledger"=> "Insurance Expense", "Amount"=> "-117.81", "Company"=> "LONDON DRUGS 78 POSTAL VANCOUVER BC"},{"Date"=> "2013-12-13", "Ledger"=> "Equipment Expense", "Amount"=> "-520.85", "Company"=> "ECHOSIGN xxxxxxxx6744 CA xx8.80 USD @ xx0878"},{"Date"=> "2013-12-13", "Ledger"=> "Equipment Expense", "Amount"=> "-5518.17","Company"=> "APPLE STORE #R280 VANCOUVER BC"}].each do |t|
      @benchy.add_transaction t
    end

    expect(@benchy.get_category_expenses).to eq(
      [{:category => "Insurance Expense", :transactions => [{:Date => "2013-12-13", :Ledger => "Insurance Expense", :Company => "LONDON DRUGS POSTAL VANCOUVER BC", :Amount => -117.81}], :totalExpenses => -117.81},
      {:category => "Equipment Expense", :transactions => [{:Date => "2013-12-13", :Ledger => "Equipment Expense", :Company => "ECHOSIGN", :Amount => -520.85}, {:Date => "2013-12-13", :Ledger => "Equipment Expense", :Company => "APPLE STORE VANCOUVER BC", :Amount => -5518.17}], :totalExpenses => -6039.02}
      ]
    )
  end

  it "should have a list of daily calculated balances. (With rolling balances)" do
    [{"Date"=> "2013-12-13", "Ledger"=> "Equipment Expense", "Amount"=> "-520.85", "Company"=> "ECHOSIGN xxxxxxxx6744 CA xx8.80 USD @ xx0878"},{"Date"=> "2013-12-14", "Ledger"=> "Equipment Expense", "Amount"=> "-5518.17","Company"=> "APPLE STORE #R280 VANCOUVER BC"},{"Date"=>"2013-12-13", "Ledger"=> "Insurance Expense", "Amount"=> "-117.81", "Company"=> "LONDON DRUGS 78 POSTAL VANCOUVER BC"}].each do |t|
      @benchy.add_transaction t
    end

    expect(@benchy.get_daily_balances).to eq([
      {:date => "2013-12-13", :balance => -638.66},
      {:date => "2013-12-14", :balance => -6156.83}])
  end

end
