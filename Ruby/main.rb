#!/usr/bin/env ruby
require 'pdf/reader'

# get page index and lines for a specific argument
# @pages: total pages in the pdf
# @arg: it should be a title name
def getArgInfo(pages, arg)
	pages.each do |page|						# loop through the pages
		lines = page.text.scan(/^.+/)			# catching all line on that page
		
		varityOfArg = []						# checking variety of arguments after been converted to text
		varityOfArg << arg						# normal case
		varityOfArg << arg.capitalize			# first letter capital
		varityOfArg << arg.upcase				# upercase all letters
		varityOfArg << arg.downcase				# lowercase all letters
		varityOfArg << arg[0] + " " + arg[1..arg.length - 1] # split the first letter with the rest of the word
		varityOfArg << arg[0].capitalize + " " + arg[1..arg.length - 1].capitalize
		varityOfArg << arg[0].upcase + " " + arg[1..arg.length - 1].upcase
		varityOfArg << arg[0].downcase + " " + arg[1..arg.length - 1].downcase
		
		i = 0
		ln = varityOfArg.length

		while i <= ln
			if lines.include? varityOfArg[i]						# determining if this argument exist on this page
				return pages.index(page), lines, varityOfArg[i]		# return page index, page lines and arguments which has been found
			end
			i = i + 1
		end
	end
end

# Searching content after an argument
# @pages: total pages in the pdf
# @arg: it should be a title name
def search_after(pages, arg)
	argInfo = getArgInfo(pages, arg) 		# get argument info
	
	if(argInfo[0].is_a? Integer)
		idx = argInfo[1].index(argInfo[2]) 	# get index of argument in one line within the page's lines
		ln = argInfo[1].length				# get length of lines for one page
		i = idx
		line = ""
		while i <= ln
			i = i + 1
			line += "#{argInfo[1][i]} "
		end
		return line
	else
		return false
	end
end

# Searching content before an argument
# @pages: total pages in the pdf
# @arg: it should be a title name
def search_before(pages, arg)
	argInfo = getArgInfo(pages, arg)		# get argument info
	
	if(argInfo[0].is_a? Integer)
		idx = argInfo[1].index(argInfo[2])	# get index of argument in one line within the page's lines
		ln = argInfo[1].length				# get length of lines for one page
		i = 0
		line = ""
		while i < idx
			line += "#{argInfo[1][i]} "
			i = i + 1
		end
		return line
	else
		return false
	end
end

# Searching content after an argument until the last page
# @pages: total pages in the pdf
# @arg: it should be a title name
def search_to_end(pages, arg)
	line = ""
	line += "#{search_after(pages, arg)} "

	argInfo = getArgInfo(pages, arg)

	if(argInfo[0].is_a? Integer)
		ln = pages.length
		i = argInfo[0] + 1
		while i < ln
			line +=  "#{search_entire_page(pages, i)} "
			i = i + 1
		end

		return line
	else
		return false
	end
end

# Searching content before an argument until the first page
# @pages: total pages in the pdf
# @arg: it should be a title name
def search_to_first(pages, arg)
	line = ""
	
	argInfo = getArgInfo(pages, arg)

	if(argInfo[0].is_a? Integer)
		idx = argInfo[1].index(argInfo[2])
		i = 0
		while i < argInfo[0]
			line +=  "#{search_entire_page(pages, i)} "
			i = i + 1
		end

		line += "#{search_before(pages, argInfo[2])} "

		return line
	else
		return false
	end
end

# Searching between two title, the it returns entire content in between
# @pages: total pages in the pdf
# @argFrom: it should be a title name that we want to start
# @argTo: it should be a title name that we want to finish
# This scenario is for catching content between two title
def search_between(pages, argFrom, argTo)
	argFromInfo = getArgInfo(pages, argFrom)
	argToInfo = getArgInfo(pages, argTo)

	if argFromInfo[0].is_a? Integer and argToInfo[0].is_a? Integer
		line = ""
		line +=  "#{search_after(pages, argFromInfo[2])} "

		i = argFromInfo[0] + 1
		while i < argToInfo[0]
			line +=  "#{search_entire_page(pages, i)} "
			i = i + 1
		end
		

		line +=  "#{search_before(pages, argToInfo[2])}"

		return line
	else
		return false
	end
end

# Get entrie page content, in this case we suppose that between title A and title B there are one to many pages
# @pages: total pages in the pdf
# @pageno: the page number that we want its content
def search_entire_page(pages, pageno)
	return pages[pageno].text.scan(/^.+/).join(" ")
end

# Starting time execution
start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

if ARGV.length != 2
	puts "The number of arguments is not correct. it should be two arguments. At first, you should specify that you want to convert pdf to text or XML(-t, -x), then you should specify the address of your file."
	exit
else
	convertor = ""
	for arg in ARGV
		if arg == "-x"
			convertor = arg
		elsif arg == "-t"
			convertor = arg
		else
			# Start converting using PDF-Reader
			PDF::Reader.open(arg) do |reader|
				puts "Converting : #{arg}"
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
				
				# Extract the content
				titre = search_before(reader.pages, "Abstract")
				abstract = search_between(reader.pages, 'Abstract', 'Introduction')
				auteur = File.basename(arg, ".pdf")
				introduction = search_between(reader.pages, "Introduction", "2 ")
				corps = search_between(reader.pages, "2 ", "Discussion")
				discussion = search_between(reader.pages, 'Discussion', 'Conclusions')
				conclusion = search_between(reader.pages, 'Conclusions', 'References')
				biblio = search_to_end(reader.pages, "References")
				
				fileBasenmae = File.basename(arg)
				if(convertor == "-x")
					File.write fileBasenmae.split(".")[0]+'.xml', "<article>\n<preamble>" + (fileBasenmae ? fileBasenmae : 'Not Detected!') + "</preamble>\n<titre>" + (titre ? titre : 'Not Detected!') + "</titre>\n<auteur>" + (auteur ? auteur : 'Not Detected!') + "</auteur>\n<abstract>" + (abstract ? abstract : 'Not Detected!') + "</abstract>\n<introduction>" + (introduction ? introduction : 'Not Detected!') + "</introduction>\n<corps>" + (corps ? corps : 'Not Detected!') + "</corps>\n<conclusion>" + (conclusion ? conclusion : 'Not Detected!') + "</conclusion>\n<discussion>" + (discussion ? discussion : 'Not Detected!') + "</discussion>\n<biblio>" + (biblio ? biblio : 'Not Detected!') + "</biblio>\n</article>"
				elsif(convertor == "-t")
					File.write fileBasenmae.split(".")[0]+'.txt', "<article>\n<preamble>" + (fileBasenmae ? fileBasenmae : 'Not Detected!') + "</preamble>\n<titre>" + (titre ? titre : 'Not Detected!') + "</titre>\n<auteur>" + (auteur ? auteur : 'Not Detected!') + "</auteur>\n<abstract>" + (abstract ? abstract : 'Not Detected!') + "</abstract>\n<introduction>" + (introduction ? introduction : 'Not Detected!') + "</introduction>\n<corps>" + (corps ? corps : 'Not Detected!') + "</corps>\n<conclusion>" + (conclusion ? conclusion : 'Not Detected!') + "</conclusion>\n<discussion>" + (discussion ? discussion : 'Not Detected!') + "</discussion>\n<biblio>" + (biblio ? biblio : 'Not Detected!') + "</biblio>\n</article>"
				else
					puts "ERROR: There is a problem to determin the first argument"
					exit
				end
			end
		end
	end # ARGV

	# code to time
	finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)

	diff = finish - start # Gets time is seconds as a float

	puts "Execution Time is: #{diff} seconds!"
end # if