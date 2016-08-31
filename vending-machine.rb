#!/usr/bin/ruby
# vending-machine.rb
# Vending Machine
# 
# The goal of this program is to model a vending machine
# and the state it must maintain during it's operation.
# How exactly the actions on the machine are driven is
# left intentionally vague and is up to the implementor.
# 
# The machine works like all vending machines: 
# it takes money then gives you items. The vending machine
# accepts money in the form of nickels, dimes, quarters, 
# and paper dollars. You must have at least have 3 primary
# items that cost $0.65, $1.00, and $1.50. The user may
# hit a "coin return" button to get back the money they've
# entered so far. If you put more money in than the item's
# price, you get change back.
# 
# Specification
# 
# The valid set of actions on the vending machine are:
# 
# NICKEL(0.05), DIME(0.10), QUARTER(0.25), DOLLAR(1.00) 
# - insert money
# COIN RETURN - returns all inserted money
# GET-A, GET-B, GET-C - select item A ($0.65), 
# B ($1), or C ($1.50)
# SERVICE - a service person opens the machine and sets
# the available changeand items
#
# The valid set of responses from the vending machine are:
# 
# NICKEL, DIME, QUARTER - return coin
# A, B, C - vend item A, B, or C
# The vending machine must track the following state:
# 
# available items - each item has a count, a price, and
# a selector (A,B,or C)
# available change - # of nickels, dimes, quarters, and
# dollars available
# currently inserted money

class VendingMachine
	def initialize()
  		@currency_conversions = {
      "nickels" => 0.05,
      "dimes" => 0.10,
      "quaters" => 0.25,
      "dollars" => 1.00
    }
    @current_money = {
      "nickels" => 0,
      "dimes" => 0,
      "quaters" => 0,
      "dollars" => 0
    }
    @available_items = Hash.new
	end

  def refill_money(money)
    # Setup the money. Store it in a hash.
    # We have to assume that money can be added later.
    # Our constrain is that we only accept the mentioned
    # denominations.
    money.each{|name,count|
      @current_money[name] += count
    }
  end

  def refill_items(items)
    # This has been built to allow for new items to be added.
    # This katar will only focus on A,B,C items.
    items.each{|item,hash|
      # Is the item in our list?
      initialize_item(item)
      # We need to set the price. Could be a new price.
      # TBH we don't really care what the price is as long
      # as it is set.
      change_item_cost(item,hash)
      # Update the stock.
      update_stock(item,hash)
    }
  end

  def initialize_item(item)
    @available_items[item] = { "amount" => 0, "price" => 0 } unless @available_items.has_key?(item)
  end
  
  def change_item_cost(item,hash)
    if hash.has_key?("price")
      @available_items[item]["price"]=hash["price"]
    end
  end

  def update_stock(item,hash)
    # This could be turned into a oneliner with a proc
    # at the cost of readability.
    if @available_items.has_key?(item)
      @available_items[item]["amount"] += hash["amount"]
    else
      @available_items[item] = hash["amount"]
    end
  end

  def current_available_change
    # Output the current change available.
    puts @current_money
  end

  def current_available_items
    # Output the current items in stock.
    puts @available_items
  end
  private :change_item_cost, :update_stock, :initialize_item
end

vendingmachine = VendingMachine.new
vendingmachine.refill_money({
    "nickels" => 100,
    "dimes" => 100,
    "quaters" => 100,
    "dollars" => 50
  })
vendingmachine.refill_items({
    "A" => { "amount" => 10, "price" => 0.65 },
    "B" => { "amount" => 10, "price" => 1},
    "C" => { "amount" => 10, "price" => 1.50}
  })
vendingmachine.current_available_change
vendingmachine.current_available_items