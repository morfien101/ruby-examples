# This is 3 different ways to match data in ruby.
# I used a simple fizz buzz example that I found online to do this.
# Basically it said fix this.
puts "Wrong!"
(1..20).each{|i|
	if i%3==0
		puts "Buzz"
	elsif i%5==0
		puts "Fizz"
	elsif i%15==0
		puts "FizzBuzz"
	else
		puts i
	end
}

# This is by far the easiest to read and to remember.
# Only thing to remember here is do your biggest matches first. Specific to this example.
puts "if statements"
(1..20).each{|i|
	if i%15==0
		puts "FizzBuzz"
	elsif i%5==0
		puts "Fizz"
	elsif i%3==0
		puts "Buzz"
	else
		puts i
	end
}

# Here we use a lamba function to return a true or false value.
# These are useful when you want to do adhoc tests that are not available
# to you normally. In this case we couldn't just use i%<number> 
# as i is not available.
puts "Case statements"
(1..20).each{ |i|
	case i
	when -> (n){n%15 == 0}
		puts "FizzBuzz"
	when -> (n){n%5 == 0}
		puts "Fizz"
	when -> (n){n%3 == 0}
		puts "Buzz"
	else
		puts i
	end
}

# This time we move all the inteligence into a function. 
# We setup the rules in a hash. This could be useful if you wanted to
# build the matching up over time. The hash could be added to later and
# the code would not need to change to allow for the new match statement.
puts "Functions!"
def moduloa(hash,number) 
	hash.each{|mod,string|
		if number % mod == 0
			puts string
			return false
		end
	}
	return true
end

xhash={15=>"FizzBuzz",5=>"Fizz",3=>"Buzz"}
(1..20).each{|i|
	if moduloa(xhash,i)
		puts i
	end
}