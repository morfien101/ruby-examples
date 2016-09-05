# Question:
# For this question, you are given a log file from a simple web server.
# Each line in the log file contains a URL and nothing else. Your job
# is to write code that will download the log file from the internet, 
# process it, and return the most popular URL in the file. You do not 
# need to normalize the URLs in the log files. If more than one URL is 
# tied for the most popular, you just need to return any one of them.

# Notes:
# In this question I wrote my own ruby based sorting algorithm.
# It basically just loops through a hash and check to see if the 
# current thing it has is smaller than the current thing it is 
# inspecting. Its very cpu hungry and can be improved greatly
# by using some built in ruby sorting methods.

require "net/https"
require "uri"
require "benchmark"
file = "https://gist.githubusercontent.com/anonymous/d2ec2461468d4a0372db/raw/b1eb88fa20b147deaafa9e38768174d79f705805/gistfile1.txt"

# First thing we need to do is get the file which contains log files.
# Example:
# http://www.example.com
# http://www.example.com/2014/07/06/us/california-missing-marine-wife/index.html
# http://www.example.com/profile
# http://www.example.com/2014/07/07/showbiz/celebrity-news-gossip/jay-z-solange-fight-lucky-magazine/index.html
# http://www.example.com/world
# http://www.example.com/justice
# http://www.example.com/2014/07/07/showbiz/celebrity-news-gossip/jay-z-solange-fight-lucky-magazine/index.html
# http://www.example.com/trends
# http://www.example.com/2014/07/07/health/diet-fitness/irpt-weight-loss-kerry-hoffman/index.html

# Create an URI object that will be used later.
uri = URI.parse(file)
# Here we prep the HTTP object. 
# uri.host = gist.githubusercontent.com
# uri.port = 443
http = Net::HTTP.new(uri.host,uri.port)
# prep to use HTTPS
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.open_timeout = 1
# Confusingly you need to tell ruby to use the HTTP object to
# run a HTTP Method...
# request_uri = anonymous/d2ec2461468d4a0372db/raw/b1eb88fa20b147deaafa9e38768174d79f705805/gistfile1.txt
response = http.request(Net::HTTP::Get.new(uri.request_uri))

# We CAN NOT use a single hash here because Ruby appears to link the values
# when assigning multiple times. Basically we have it once and everything
# derived from it is a pointer.

#stuff = Hash.new
#response.body.split("\n").each{|l|
#  if stuff.has_key?(l)
#    stuff[l] += 1
#  else
#    stuff[l] = 1
#  end
#}

def hash_values(str_value)
  stage_hash = Hash.new
  str_value.split("\n").each{|l|
    if stage_hash.has_key?(l)
      stage_hash[l] += 1
    else
      stage_hash[l] = 1
    end
  }
  return stage_hash
end

# Time how long it takes to sort with the built in ruby method.
sort_hash = hash_values(response.body)
time_sort = Benchmark.measure{
  top = sort_hash.sort_by{|n,o| o}.reverse
}

# We need to do it again outside the block so that we don't
# time the printing to the console. 
# Printing is very expensive.
top = sort_hash.sort_by{|n,o| o}.reverse
puts "///// SORT ////////"
(0..19).each{|ti|
  puts "#{top[ti][1]} - #{top[ti][0]}"
}

def get_logs(logs,n)
  top_array = Array.new
  # cycle n time to get all the logs.
  (1..n).each{|i|
    i -= 1
    # cycle through the logs hash
    logs.each{|k,v|
      # set top_array to current value if it is blank
      top_array[i] = [k,v] if top_array[i].nil?

      # if top_array current < current value set to
      #puts top_array[i]
      logs.each{|url,count|
        if logs[top_array[i][0]] < count
          top_array[i] = [url,count]
        end
      }
    }
    logs.delete(top_array[i][0])
  }
  return top_array
end

# Here we time the iteration of a single loop.
# We have to set the vaule of the hash and then reset it
# becasue ruby passes a pointer not a copy.
# Again measure and then print outside.
loop_hash1 = hash_values(response.body)
time_loop = Benchmark.measure{
  get_logs(loop_hash1,1)
}
loop_hash1 = hash_values(response.body)
func_log = get_logs(loop_hash1,1)
puts "///// Single ////////"
func_log.each{|log|
  puts "#{log[1]} - #{log[0]}"
}

# Now measure with 20 iterations.
loop_hash2 = hash_values(response.body)
loop_x10 = Benchmark.measure {
  get_logs(loop_hash1,20)
}

loop_hash2 = hash_values(response.body)
func_logs = get_logs(loop_hash2,20)
puts "///// FUNC ////////"
func_logs.each{|log|
  puts "#{log[1]} - #{log[0]}"
}

print "\n\n\n\n\n"
puts "Built in sort method: "
puts time_sort.real
puts "Created single sorting method: "
puts time_loop.real
puts "Create sorting method top 50: "
puts loop_x10.real
puts "Time lost on a single sort in msec: "
puts (time_loop.real - time_sort.real).round(5)
puts "Time lost on a 20x sort in msec: "
puts (loop_x10.real - time_sort.real).round(5)

# Conclusion: 
# The built in ruby sort method is very fast. Most likely written
# as a C module. The time lost is small but grows exponetially 
# with the size of the lists.