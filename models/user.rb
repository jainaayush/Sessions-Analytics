require "json"
require 'byebug'

class User

	WINDOW_MILLSEC = 600000

	FILE = "../events.json"

	def read_file
		json_from_file = File.read(FILE)
		hash = JSON.parse(json_from_file)

		all_events = hash['events']
		output = []
		hashTable = Hash.new{|h, k| h[k] = []}

		all_events.each do |event|

			hashTable[event['visitorId']].push(event['timestamp'])

			if output.any? and output.map{|a| a.keys}.flatten.include?(event['visitorId'])
				obj = output.select { |v| v[event['visitorId']]}[0]

				val = obj.values
				if val[0]['startTime'].join.to_i + WINDOW_MILLSEC >= event['timestamp']
					val[0]["pages"].push(event['url'])
				else
					obj.merge!({"duration"=> 0, "pages"=> [event['url']], 'startTime' => [event['timestamp']]})
				end	

				if hashTable.keys[0] == event['visitorId']
					time = hashTable.values[0]
					next if time[2].nil?
					val[0]['duration'] = time[1] - time[2]
					val[0]['startTime'] = time[2]
				else
					time = hashTable.values[1]
					next if time[2].nil?
					val[0]['duration'] = time[0] - time[2]
					val[0]['startTime'] = time[2]
				end

			else
				output <<  { event['visitorId'] => { 'duration' => [event['timestamp']], 'pages' => [event['url']], 'startTime' => [event['timestamp']] }}
			end

		end
		puts "sessionsByUser"=> output.reverse
	end

end

user = User.new
user.read_file