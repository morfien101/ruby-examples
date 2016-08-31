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
# the available change and items
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
#
# Example 1: Buy B with exact change
# Q, Q, Q, Q, GET-B
# -> B
# 
# Example 2: Start adding change but hit coin return to 
# get change back
# Q, Q, COIN-RETURN
# -> Q, Q
# 
# Example 3: Buy A without exact change (return $.35)
# DOLLAR, GET-A
# -> A, Q, D

class VendingMachine
	def initialize()
  	@currency_conversions = {
      "nickel" => 0.05,
      "dime" => 0.10,
      "quater" => 0.25,
      "dollar" => 1.00
    }
    @current_money = {
      "nickel" => 0,
      "dime" => 0,
      "quater" => 0,
      "dollar" => 0
    }
    @available_items = Hash.new
    @current_transaction = { 
      :current_money => Array.new,
      :change_required => 0
    }
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
    @available_items[item] = { "stock" => 0, "price" => 0 } unless @available_items.has_key?(item)
  end
  
  def change_item_cost(item,hash)
      @available_items[item]["price"] = hash["price"] if hash.has_key?("price")
  end

  def update_stock(item,hash)
    # This could be turned into a oneliner with a proc
    # at the cost of readability.
    if @available_items.has_key?(item)
      @available_items[item]["stock"] += hash["stock"]
    else
      @available_items[item] = hash["stock"]
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

  def insert_coin(coin)
    @current_transaction[:current_money] << coin
    @current_money[coin] += 1
    display_current_total
  end

  def display_current_total
    puts "$#{current_money_total}"
  end

  def return_money
    returned_coins = Array.new
    if @current_transaction[:current_money].empty?
      puts "Error: No coins inserted!"
    else
      @current_transaction[:current_money].each {|coin|
        @current_money[coin] -= 1
        returned_coins << coin
      }
      @current_transaction[:current_money] = Array.new
      print "["
      returned_coins.each_index{|i| 
        print returned_coins[i]
        print "," unless returned_coins[i + 1].nil?
      }
      print "]\n"
    end
  end

  def vend_item(item)
    # Check for stock and vaild item
    # check if the current total of money is >= price of item
    # vend item
    # subtract cost from current money.
    # check if we need change
    if @available_items.has_key?(item)
      if @available_items[item]["price"] <= current_money_total
        if @available_items[item]["stock"] > 0
          t_actionable, change_a = issue_change(@available_items[item]["price"])
          if t_actionable
            issue_item(item)
            @current_transaction[:current_money] = Array.new
            print "["
            change_a.each{|c| print "#{c},"} unless change_a.empty?
            print "#{item}]\n"
          else
            # Until I fix the crazy ruby floats thing.
            # This will not be triggered.
            puts "We can not complete the transaction. Change can not be given."
            return_money
          end
        else
          puts "No stock. Returning money."
          return_money
          return false
        end
      else
        puts "Not enough money inserted."
      end
    else
      puts "Invaild item. Returning money."
      return_money
      return false
    end
  end

  def issue_change(price)
    # issue change.
    @current_transaction[:change_required] = current_money_total - price
    return calculate_change
  end

  def issue_item(item)
    # -1 from stock.
    # Print Item to console to mimic issue.
    @available_items[item]["stock"] -= 1
  end

  def current_money_total
    total = 0.0
    @current_transaction[:current_money].each{|c|
      total += @currency_conversions[c]
    }
    return total
  end

  def calculate_change
    rn=@current_transaction[:change_required]
    return_array = Array.new
    transaction_actionable_value = true

    # check that we have the coins in stock.
    until rn <= 0
      change_available = false
      if rn >= @currency_conversions["dollar"] && currency_instock?("dollar")
        return_array << "dollar"
        @current_money["dollar"] -= 1
        rn = (rn - @currency_conversions["dollar"]).round(2)
        change_available = true
      elsif rn >= @currency_conversions["quater"] && currency_instock?("quater")
        return_array << "quater"
        @current_money["quater"] -= 1
        rn = (rn - @currency_conversions["quater"]).round(2)
        change_available = true
      elsif rn >= @currency_conversions["dime"] && currency_instock?("dime")
        return_array << "dime"
        @current_money["dime"] -= 1
        rn = (rn - @currency_conversions["dime"]).round(2)
        change_available = true
      elsif rn >= @currency_conversions["nickel"] && currency_instock?("nickel")
        # FOR SOME REASON UNKNOWN TO ME RUBY SAYS 0.35-0.3 = 0.04999999999999999 ???
        # DFUQ is that about? 0.35 - 0.3 should be 0.05
        # Fixed with (rn - number).round(2)
        # we have to check here if we have stock of nickles.
        # If not we may have to go up the scale and give larger change
        # or return the money and not vend the item.
        # track lost money due to change issues.
        # remember to put the money in the array back in stock.
        return_array << "nickel"
        @current_money["nickel"] -= 1
        rn = (rn - @currency_conversions["nickel"]).round(2)
        change_available = true
      end
      unless change_available
        # Error out becasue we can't issue change.
        transaction_actionable_value = false
        # Return collected change so far back into stock.
        return_array.each{|m|
          refill_money({m => 1})
        }
        # Clear the return money.
        return_array = []
        # Exit out the change calculation loop.
        break
      end
    end
    @current_transaction[:change_required] = 0
    return transaction_actionable_value, return_array
  end

  def currency_instock?(name)
    return @current_money[name] > 0
  end

  private :change_item_cost, :update_stock, :initialize_item
  private :currency_instock?, :calculate_change, :current_money_total
  private :issue_item, :issue_change
end


# Testing actions.
vendingmachine = VendingMachine.new
vendingmachine.refill_money({
    "nickel" => 500,
    "dime" => 500,
    "quater" => 500,
    "dollar" => 50
  })
vendingmachine.refill_items({
    "A" => { "stock" => 10, "price" => 0.65 },
    "B" => { "stock" => 10, "price" => 1},
    "C" => { "stock" => 10, "price" => 1.50}
  })
#vendingmachine.current_available_change
#vendingmachine.current_available_items
vendingmachine.return_money
["quater","quater","quater","quater"].each{|c|
  vendingmachine.insert_coin(c)
}
vendingmachine.return_money
["quater","quater","quater","quater"].each{|c|
  vendingmachine.insert_coin(c)
}
vendingmachine.vend_item("A")
["quater","quater"].each{|c|
  vendingmachine.insert_coin(c)
}
vendingmachine.vend_item("A")
vendingmachine.return_money

(["dollar"]*100).each{|c|
  vendingmachine.insert_coin(c)
}
vendingmachine.vend_item("A")
vendingmachine.current_available_change

(1..3).each{puts " "}

# Example 1: Buy B with exact change
puts "Example 1"
["quater","quater","quater","quater"].each{|c|
  vendingmachine.insert_coin(c)
}
vendingmachine.vend_item("B")

# Example 2: Start adding change but hit coin return to 
# get change back
# Q, Q, COIN-RETURN
puts "Example 2"
["quater","quater"].each{|c|
  vendingmachine.insert_coin(c)
}
vendingmachine.return_money

# Example 3: Buy A without exact change (return $.35)
# DOLLAR, GET-A
# -> A, Q, D
puts "Example 3"
["dollar"].each{|c|
  vendingmachine.insert_coin(c)
}
vendingmachine.vend_item("A")
