class SlackClient
  require_relative '../environment.rb'
  require_relative './bot.rb'
  require 'open-uri'
  require 'json'
  require 'websocket-client-simple'

  def initialize
    @bot_token = SLACK_BOT_TOKEN
    bot = Bot.new
    @ws = nil
    start_session(bot)
  end

  def start_session(bot)
    loop do
      connect
      maintain_session_for bot
    end
  end

  def connect
    @i = 0
    url = get_url
    try = 0

    begin
      try += 1
      @ws = WebSocket::Client::Simple.connect url
    rescue
      puts "Try #{try.to_s}: Failed to Connect...retrying"
      retry
    end
  end

  def maintain_session_for(bot)
    client = self
    @ws.on :open do
      puts "CONNECTED!"
    end
    @ws.on :error do |e|
      p e
    end
    @ws.on :message do |msg|
      msg = msg.to_s
      message = JSON.parse(msg)
      puts message
      if message['type'] == "message"
        bot.process(message['text'].chomp.downcase, message['channel'], client)
      end
    end
    @ws.on :close do
      puts "Connection Closed. Goodbye!"
    end
    sleep 30
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


