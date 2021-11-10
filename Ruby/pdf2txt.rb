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
	title = ""
	paragraph = ""
	paragraphs = []
	reader.pages.each do |page|
		lines = page.text.scan(/^.+/)
		x = 0
		# Title
		lines.each do |line|
			if line.length < 40
				title += " #{line}"
				if lines.index(line) == 0
					break
				end
			end
		end
		# Abstract
		lines.each do |line|
			if line.length > 40
				paragraph += " #{line}"
				paragraphs << paragraph
				if lines.index(line) == 10 # if abstract has 10 lines
					break
				end
			end
			paragraph = ""
		end
		break
	end

	# Inserting to the Text file
	File.write filename+'.xml', "<article>\n<preamble>" + filename + "</preamble>\n<titre>" + title + "</titre>\n<abstract>" + paragraphs.join("") + "</abstract>\n</article>"
	end # reader

end # each


# code to time
finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)

diff = finish - start # Gets time is seconds as a float

puts "Execution Time is: #{diff} seconds!"