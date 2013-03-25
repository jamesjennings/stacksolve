#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'json'
require 'open-uri'

@user_input = ARGV[0]
@user_function = ARGV[1]
@user_stack_key = ARGV[2]
@page = 1
@item = 0
@answers = []
@urlBase = "http://api.stackexchange.com/2.1/"
@common_url = "&pagesize=100&order=desc&site=stackoverflow&todate=1363060800"

def run_snippet
	# puts "run_snippet"

	while true 
		# puts "@page #{@page}"
		# puts "@item #{@item}"
		if @item >= @answers.count
			if !get_next_page
				return
			end
		end
		if run_snippet_go
			puts "Stop? y/n"
			answer = $stdin.gets.chomp
			if answer == "y"
				return true
			end
		end
		@item = @item + 1
	end
	false
end

def run_snippet_go
	begin
		# puts "run_snippet_go"
		# puts "@answers[@item] #{@answers[@item]}"
		answer = @answers[@item]["body"]
		# puts "answer #{answer}"
		answer_id = @answers[@item]["answer_id"]
		question_id=@answers[@item]["question_id"]
		link = @answers[@item]["link"]
		matches = Array.new
		answer.scan(/<code>(.*?)<\/code>/mx) do |match|
			if match == nil
				next 
			end
			
			methodNames = []
			match[0].scan(/[\s\t]*def[\s\t]*(\w*)[\s\t]*\(?(\w*)\)?/) do |functionName, paramName|
				
				methodNames << functionName
			end 

			cleanedMatch = match[0]
			cleanedMatch = cleanedMatch.gsub(/&gt;/, ">")
			cleanedMatch = cleanedMatch.gsub(/&lt;/, "<")
			cleanedMatch = cleanedMatch.gsub(/&amp;/, "&")

			unless methodNames.count == 0
				begin 
					# puts "\n\n***************************************************************"
					# puts "Found method block: #{cleanedMatch}"
					eval cleanedMatch
					for aMethod in methodNames do
						begin
							# puts "Calling #{aMethod} #{@user_input}"
							theAnswer = eval "#{aMethod} #{@user_input}"
							puts "We have an answer! #{theAnswer}"
							return true
						rescue Exception => ex
							# puts "Inner ex: #{ex}"
						end
					end

				rescue Exception => ex
					# puts "Outer ex: #{ex}"

				ensure
				end
			end
		end
	rescue Exception => ex
		# puts "Mega ex: #{ex}"

	ensure
	end


	return false
end

def get_next_page
	# puts "get_next_page"
	question_url = @urlBase + "search?sort=relevance&tagged=ruby&intitle=#{URI::encode(@user_function)}&page=#{@page}" + @common_url
	if @user_stack_key
		question_url = question_url + "&key=#{@user_stack_key}"
	end
	url = URI(question_url)
	r = Net::HTTP.get_response(url)	 
	sio = StringIO.new( r.body )
	gz = Zlib::GzipReader.new( sio ) 

	questions = JSON.parse(gz.read())
	# puts "question_url #{question_url}"
	# puts "\n\nquestions #{questions}" 
	questionIds = Array.new

	if questions["items"] == nil || questions["items"].count == 0
		return false
	end

	for question in questions["items"] do
		questionIds << question["question_id"] 
	end

	answer_url = @urlBase + 'questions/' + questionIds.join(';') + '/answers/?sort=activity&filter=!9hnGsyXaB' + @common_url;
	if @user_stack_key
		answer_url = answer_url + "&key=#{@user_stack_key}"
	end
	# puts "answer_url #{answer_url}"
	url = URI(answer_url)
	r = Net::HTTP.get_response(url)	 
	sio = StringIO.new( r.body )
	gz = Zlib::GzipReader.new( sio ) 
	@answers = JSON.parse(gz.read())
	# puts "\n\n\n@answers #{@answers}"
	
	@answers = @answers["items"]
	@page = @page + 1
	@item = 0
	true
end

unless run_snippet
	puts "No answer was found :("
end