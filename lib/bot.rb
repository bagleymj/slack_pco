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
    bot_words = ['band','musicians']
    interface = Interface.new
    #define bot behavior
    if bot_words.include? message_text
      team_name = nil
      case message_text
      when 'band', 'musicians'
        team_name = 'band'
      end
      team = interface.get_team_for channel, team_name
      team.each do |member|
        client.reply(member, channel)
      end
    end
  end

  
end
