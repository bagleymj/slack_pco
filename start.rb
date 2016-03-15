def launch_bot
  require './lib/bot.rb'
  Bot.new
end

if File.file?('environment.rb')
  #If you've been here already, fire up the bot
  launch_bot
else
  #Create environment.rb
  puts "It looks like it may be your first time here."
  puts "Please set up the API keys for your Slack and Planning Center Accounts"
  puts "\n\n\n"
  file = File.new('environment.rb','w')
  puts "Please enter PCO Application ID:"
  file.puts "PCO_APP_ID = \"" + gets.chomp + "\""
  puts "\nPlease enter PCO Secret:"
  file.puts "PCO_SECRET = \"" + gets.chomp + "\""
  puts "\nPlease enter Slack API Token:"
  file.puts "SLACK_API_TOKEN = \"" + gets.chomp + "\""
  puts "\nPlease enter Slack BOT Token:"
  file.puts "SLACK_BOT_TOKEN = \"" + gets.chomp + "\""
  file.close
  #fire up the bot
  launch_bot
end
