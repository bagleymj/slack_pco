class Bot
  require_relative '../environment.rb'
  require_relative './slack_client.rb'
  require_relative './interface.rb'
  require 'pco_api'
  require 'open-uri'
  require 'json'
  require 'websocket-client-simple'
  require 'date'

  def get_client
    slack_client = SlackClient.new
    client = slack_client.connect
    return client
  end

  def process(message_text, channel, client)
    bot_words = ['band']
    interface = Interface.new
    #define bot behavior
    case message_text
    when 'band'
      band = interface.get_band_list_for channel
      band.each do |member|
        client.reply(member, channel)
      end
    end
  end

  
end
