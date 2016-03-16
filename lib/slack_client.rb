require_relative '../environment.rb'
require 'open-uri'
require 'json'
require 'websocket-client-simple'

class SlackClient

  def connect
    bot_token = SLACK_BOT_TOKEN
    response = open('https://slack.com/api/rtm.start?token='+ bot_token + '&pretty=1').read
    rtm = JSON.parse(response)
    url = rtm['url']
    ws = WebSocket::Client::Simple.connect url
    ws.on :open do
      puts "CONNECTED!"
      puts "To exit simply type 'exit' in the console and press ENTER."
    end
    ws.on :error do |e|
      p e
    end
    ws.on :message do |msg|
      msg = msg.to_s
      message = JSON.parse(msg)
      puts message
    end
    ws.on :close do
      puts "Connection Closed. Goodbye!"
    end
    loop do
      console = gets.chomp.downcase
      if console == "exit"
        ws.close
        break
      end
    end
  end


end
