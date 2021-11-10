#!/usr/bin/env ruby
require 'pdf/reader'

# Starting time execution
start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

ARGV.each do |filename|
	# Start converting using PDF-Reader
	PDF::Reader.open(filename) do |reader|

		puts "Converting : #{filename}"
		pageno = 0
		txt = reader.pages.map do |page| 

		pageno += 1
		begin
			print "Converting Page #{pageno}/#{reader.page_count}\r"
			page.text 
		rescue
			puts "Page #{pageno}/#{reader.page_count} Failed to convert"
			''
		end

	end

	puts "\nWriting text to disk"
	# Spliting the text to find the Abstract
	m = txt.join(",").split("\n\n")
	m.each do |i|
		i.strip!
	end

	# Finding the Abstract if it exists its title
	i = 0
	abstractIndex = 0
	introductionIndex = 0
	while i < m.length()
		if m[i].include?("Abstract") || m[i].include?("ABSTRACT")
			abstractIndex = i
		end
		i = i + 1
	end

	# Finding the next portion of the text that might be Introduction!
	i = 0
	while i < m.length()
		if m[i].include?("Introduction") || m[i].include?("introduction")  || m[i].include?("INTRODUCTION")  || m[i].to_s.include?("1.") || m[i].to_s.include?("I")
			introductionIndex = i
		end
		i = i + 1
	end

	# Merging the distance between the Abstract title and the Introduction title to have the portion of Abstract
	abstract = ""
	i = abstractIndex
	if abstractIndex == 0
		abstract = "There is no Abstract to select!"
	elsif abstractIndex && introductionIndex
		while i <= introductionIndex
			abstract += m[i].to_s
			i += 1
		end
	end

	# Inserting to the Text file
	File.write filename+'.txt', "Filename: " + filename + "\nTitle: " + m.first.to_s + "\nAbstract: " + abstract
	end # reader

end # each


# code to time
finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)

diff = finish - start # Gets time is seconds as a float

puts "Execution Time is: #{diff} seconds!"#!/usr/bin/env ruby
require 'pdf/reader'

# Starting time execution
start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

ARGV.each do |filename|
	# Start converting using PDF-Reader
	PDF::Reader.open(filename) do |reader|

		puts "Converting : #{filename}"
		pageno = 0
		txt = reader.pages.map do |page| 

		pageno += 1
		begin
			print "Converting Page #{pageno}/#{reader.page_count}\r"
			page.text 
		rescue
			puts "Page #{pageno}/#{reader.page_count} Failed to convert"
			''
		end

	end

	puts "\nWriting text to disk"
	# Spliting the text to find the Abstract
	m = txt.join(",").split("\n\n")
	m.each do |i|
		i.strip!
	end

	# Finding the Abstract if it exists its title
	i = 0
	abstractIndex = 0
	introductionIndex = 0
	while i < m.length()
		if m[i].include?("Abstract") || m[i].include?("ABSTRACT")
			abstractIndex = i
		end
		i = i + 1
	end

	# Finding the next portion of the text that might be Introduction!
	i = 0
	while i < m.length()
		if m[i].include?("Introduction") || m[i].include?("introduction")  || m[i].include?("INTRODUCTION")  || m[i].to_s.include?("1.") || m[i].to_s.include?("I")
			introductionIndex = i
		end
		i = i + 1
	end

	# Merging the distance between the Abstract title and the Introduction title to have the portion of Abstract
	abstract = ""
	i = abstractIndex
	if abstractIndex == 0
		abstract = "There is no Abstract to select!"
	elsif abstractIndex && introductionIndex
		while i <= introductionIndex
			abstract += m[i].to_s
			i += 1
		end
	end

	# Inserting to the Text file
	File.write filename+'.txt', "Filename: " + filename + "\nTitle: " + m.first.to_s + "\nAbstract: " + abstract
	end # reader

end # each


# code to time
finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)

diff = finish - start # Gets time is seconds as a float

puts "Execution Time is: #{diff} seconds!"