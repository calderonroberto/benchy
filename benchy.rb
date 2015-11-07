require 'net/http'
require 'json'

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
  ## A method to add transactions with pre-processing like string
  ## cleaning and duplicate checks. This way we minimize the time cost
  ##

  def add_transaction(t)
    #TODO clean up strings and duplicates
    t['Company'] = clean_string t['Company']
    @transactions.push t
  end

  ##
  ## Let's assume we want all the data.This function will paginate
  ## until we load all the transactions specified by the API response.
  ##

  def get_data

    totalCount = i = 1

    while @transactions.length < totalCount do

      res = Net::HTTP.get_response(URI(@url + i.to_s + '.json'))

      if res.code != '200' # safety first.
        break
      end

      begin
        res_data = JSON.parse(res.body)
        res_data['transactions'].each do |t|
          add_transaction t
        end
        totalCount = res_data['totalCount']
      rescue # deploy parachutes
        puts "Error getting data from the API, likely a JSON parse Error"
      end

      i+=1

    end

    @transactions #return transactions in case client needs it

  end

  ##
  ## Method to compute the balance.
  ##

  def compute_balance

    balance = 0

    if @transactions.length == 0
      return balance #probably better to return nil
    end

    @transactions.each  do |t|
      balance += t['Amount'].to_f
    end

    balance

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


end
