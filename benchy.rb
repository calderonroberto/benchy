require 'net/http'
require 'json'
require 'date'

class Benchy

  def initialize(url)
    @url = url
    @transactions = []
  end

  ##
  ## Getters and setters.
  ##

  def url(url=nil)
    @url = url if url
    @url
  end

  def transactions(tns=nil)
    @transactions = tns if tns
    @transactions
  end


  ##
  ## A method to add transactions, while pre-processing it to appropriate
  ## types, cleaning strings and checking for duplicates. Also, JSON properties
  ## should be lowercased.
  ##
  ## In reality parse Dates like: Date.strptime(t["Date"], '%Y-%m-%d')
  ## however, since it's Y-M-D sorting is straightforward.
  ##
  def add_transaction(t)
    clean_t = {
      :date => t["Date"] || nil,
      :ledger => safe_ledger(t["Ledger"]),
      :company => clean_string(t["Company"]),
      :amount => t["Amount"].to_f || 0.0
    }
    unless @transactions.include? clean_t
     @transactions.push clean_t
    end
  end

  ##
  ## Let's assume we want all the data.This function will paginate
  ## until we load all the transactions specified by the API response.
  ##

  def get_data
    totalCount = i = 1
    @transactions = [] # ensure this object uses only up-to-date data
    while @transactions.length < totalCount do
      res = Net::HTTP.get_response(URI(@url + i.to_s + '.json'))
      if res.code != '200' # safety first.
        break
      end
      begin
        res_data = JSON.parse(res.body)
      rescue # deploy parachutes API is misbehaving
        puts "Error getting data from the API, likely a JSON parse Error"
      end
      totalCount = res_data['totalCount']
      res_data['transactions'].each do |t|
        add_transaction t
      end
      i+=1
    end
    @transactions.sort_by! { |k| k[:date] } #return transactions in case client needs it, let's sort it too ;)
  end

  ##
  ## Method to compute the balance.
  ##

  def compute_balance
    if @transactions.length == 0
      return 0.0
    end
    balance = @transactions.reduce(0.0){|balance, t| balance + t[:amount]}
    safe_float balance #ensure two decimals
  end

  ##
  ## Get categories.
  ## We will use a hash for optimal performance.
  ## Returining this hash would probably be the best choice too,
  ## however, specs say "list", so we create an array at the end.
  ##

  def get_category_expenses
    categories = {}
    @transactions.each  do |t|
      unless categories.has_key?(t[:ledger])
        categories[t[:ledger]] = {:transactions=>[], :totalExpenses=>0.0}
      end
      categories[t[:ledger]][:transactions].push t
      categories[t[:ledger]][:totalExpenses] += t[:amount]
    end
    categories_list = []
    categories.each do |k,v|
      categories_list.push({:category => k, :transactions => v[:transactions], :totalExpenses => safe_float(v[:totalExpenses])})
    end
    categories_list
  end

  ##
  ## Get Daily Rolling Balances.
  ##

  def get_daily_balances
    daily_balances  = []
    balance = 0.00
    #ensure it's sorted first
    @transactions.sort_by! { |k| k[:date] }.each_with_index do |t,i|
      balance += t[:amount]
      if i == @transactions.length-1 || t[:date] != @transactions[i+1][:date]
        daily_balances << {:date => t[:date], :balance => safe_float(balance)}
      end
    end
    daily_balances
  end

  private

  ##
  ## We could be orthodox here and remove even the Location,
  ## but sometimes it's nice to know where you spent the moola.
  ## it will test for :
  ##    words beginning with: #, x
  ##    digits and periods
  ##    the characters, and words: USD, CAD, @
  ##
  def clean_string (string)
    return string.gsub(/\s(#|x)\w+|\d|\.|\s\d|\s(USD|CAD|@)/, "")
  end


  ##
  ## Let's deal with empty ledger strings. It seems in the API they are
  ## payments received, but let's solve for other cases too, and be general.
  def safe_ledger (string)
    if string.nil? || string.empty?
      return "Unknown"
    else
      return string
    end
  end

  ## Let's keep the consistency with the API. Due to implementation
  ## in ruby, float operations might return trailing zeros or decimals
  def safe_float (num)
    return num.round(2)
  end

end
