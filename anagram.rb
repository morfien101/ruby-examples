# Author Randy Coburn
# Date: 24/09/2016
# Description: This is a simple program that will
# 				check if 2 strings are a anagram of
#				each other.
# Example:	ruby anagram.rb randycoburn coburnrandy
# http://www.dictionary.com/browse/anagram

word1 = ARGV[0].downcase
word2 = ARGV[1].downcase

# Technically if the words are the same they are not an anagram.
if word1 == word2
	puts "False"
	exit 1
end

# Change to a byte array and then sort. Match the sorted array.
if word1.bytes.sort == word2.bytes.sort
	puts "True"
	exit 0
else
	puts "False"
	exit 1
end