class SlackClient
  require_relative '../environment.rb'
  require_relative './bot.rb'
  require 'open-uri'
  require 'json'
  require 'websocket-client-simple'

  def initialize
    @bot_token = SLACK_BOT_TOKEN
    bot = Bot.new
    connect(bot)
  end

  def connect(bot)
    @i = 0
    response = open('https://slack.com/api/rtm.start?token='+ @bot_token + '&pretty=1').read
    rtm = JSON.parse(response)
    url = rtm['url']
    ws = WebSocket::Client::Simple.connect url
    @ws = ws
    maintain_session_for ws, bot
  end

  def maintain_session_for(ws, bot)
    client = self
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
      if message['type'] == "message"
        bot.process(message['text'].chomp.downcase, message['channel'], client)
      end
    end
    ws.on :close do
      puts "Connection Closed. Goodbye!"
    end
    sleep 30
    puts "refreshing connection"
    ws.close
    connect(bot)


  end

  def reply(reply_text, channel)
    @i += 1
    reply = {id: @i, type: 'message', channel: channel, text: reply_text}.to_json 
    @ws.send reply
  end

  def get_socket
    return @ws
  end

end


