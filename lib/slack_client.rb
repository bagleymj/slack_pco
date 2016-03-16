require_relative '../environment.rb'
require 'open-uri'
require 'json'
require 'websocket-client-simple'

class SlackClient
  def initialize
    @bot_token = SLACK_BOT_TOKEN
  end

  def connect
    response = open('https://slack.com/api/rtm.start?token='+ @bot_token + '&pretty=1').read
    rtm = JSON.parse(response)
    url = rtm['url']
    ws = WebSocket::Client::Simple.connect url
    maintain_session_for ws
  end

  def maintain_session_for(ws)
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
    threads = []
    threads << Thread.new {
      loop do
        console = gets.chomp.downcase
        if console == "exit"
          ws.close
          break
        end
      end
    }
    threads << Thread.new {
      sleep 30
      puts "refreshing connection"
      ws.close
      threads[0].kill
      connect
    }
    threads.each do |thread|
      thread.join
    end

  end
end


