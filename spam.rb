require 'hipchat'

count = 0
puts "Spam beginning..."

hour = Time.now.hour
day = Time.now.wday

if hour > 11 && hour < 19 && day != 0 && day != 6
  client = HipChat::Client.new("4uXICn8qRMEmPwlmGEWVps9An29ufmgK8ZFibL78", :api_version => 'v2')

  File.open("messages.txt", "r").each_line do |message|
    puts "Spamming: #{message}"
    count += 1
    client['Development'].send('GitCheck', message, :color => 'random')
  end
end

puts "Finished: #{count} messages spammed"
