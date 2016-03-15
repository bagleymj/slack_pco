def launch_app
  require './lib/bot.rb'
  require './lib/slack.rb'
  processes =[]
  processes << Thread.new{
    Slack.new
  }
  processes << Thread.new{
    Bot.new
  }
  processes.each do |thread|
    thread.join
  end
end

if File.file?('environment.rb')
  #If you've been here already, fire up the bot
  launch_app
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
  launch_app
end
