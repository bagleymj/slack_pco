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
    url = get_url
    ws = nil
    try = 0
    begin
      try += 1
      ws = WebSocket::Client::Simple.connect url
    rescue
      puts "Try #{try.to_s}: Failed to Connect...retrying"
      retry
    end
    @ws = ws
    maintain_session_for ws, bot
  end

  def maintain_session_for(ws, bot)
    client = self
    ws.on :open do
      puts "CONNECTED!"
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
    loop do
      sleep 30
      puts "Getting new URL"
      url = get_url
      puts "Refreshing Connection"
      begin
        ws.connect url
        handshake = ws.handshake
        puts handshake
        puts "Now connected to #{url}"
      rescue
        puts "Connection failed, retrying"
        retry
      end
      
    end
    #connect(bot)


  end

  def get_url
    response = open('https://slack.com/api/rtm.start?token='+ @bot_token + '&pretty=1').read
    rtm = JSON.parse(response)
    rtm['url']
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


