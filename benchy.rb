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
  ## types, cleaning strings and checking for duplicates.
  ##
  ## In reality parse Dates like: Date.strptime(t["Date"], '%Y-%m-%d')
  ## however, since it's Y-M-D sorting is straightforward.
  ##
  def add_transaction(t)
    clean_t = {
      "Date": t["Date"] || nil,
      "Ledger": t["Ledger"] || "Payment",
      "Company": clean_string(t["Company"]) || "",
      "Amount": t["Amount"].to_f || 0
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
      rescue # deploy parachutes
        puts "Error getting data from the API, likely a JSON parse Error"
      end
      totalCount = res_data['totalCount']
      res_data['transactions'].each do |t|
        add_transaction t
      end
      i+=1
    end
    @transactions #return transactions in case client needs it
  end

  ##
  ## Method to compute the balance.
  ##

  def compute_balance
    if @transactions.length == 0.0
      return 0.0 #probably better to return nil
    end
    balance = @transactions.reduce(0.0){|balance, t| balance + t[:Amount]}
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
      unless categories.has_key?(t[:Ledger])
        categories[t[:Ledger]] = {:transactions=>[], :totalExpenses=>0.0}
      end
      categories[t[:Ledger]][:transactions].push t
      categories[t[:Ledger]][:totalExpenses] += t[:Amount]
    end

    # Done, but let's create an array:
    categories_list = []
    categories.each do |k,v|
      categories_list.push({:category => k, :transactions => v[:transactions], :totalExpenses => v[:totalExpenses]})
    end
    categories_list
  end

  ##
  ## Get Daily Rolling Balances.
  ##

  def get_daily_balances
    sorted_transactions = @transactions.sort_by { |k| k[:Date] }
    daily_balances  = []
    balance = 0.00
    sorted_transactions.each_with_index do |t,i|
      balance += t[:Amount]
      if i == sorted_transactions.length-1 || t[:Date] != sorted_transactions[i+1][:Date]
        daily_balances << {:date => t[:Date], :balance => safe_float(balance)}
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
  ##    the characters, and words: USD, CA, @
  ##
  def clean_string (string)
    return string.gsub(/\s(#|x)\w+|\d|\.|\s\d|\s(USD|CA|@)/, "")
  end

  ## Let's keep the consistency with the API. Due to implementation
  ## in ruby, float operations might return trailing zeros or decimals
  def safe_float (num)
    return num.round(2)
  end

end
