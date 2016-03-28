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
    band_words = ['band','musicians']
    kids_words = ['kids','children','nursery',"childeren's ministry"]
    team_words = ['volunteers', 'team', 'everyone']
    first_impressions_words = ['welcome','coffee', 'first impressions',
                               'hospitality','parking']
    facilities_words = ['setup','tear down','set up', 'teardown', 'loading',
                        'unloading']
    av_words = ['sound','lights','av','audio','audio visual','sound guy']
    bot_words = band_words + kids_words + team_words + first_impressions_words + facilities_words + av_words
    interface = Interface.new
    #define bot behavior
    if bot_words.include? message_text.chomp.downcase
      team_name = nil
      case message_text
      when *band_words
        team_name = 'band'
      when *team_words
        team_name = 'volunteers'
      when *kids_words
        team_name = "mhc kids"
      when *first_impressions_words
        team_name = 'first impressions'
      when *facilities_words
        team_name = 'facilities'
      when *av_words
        team_name = 'audio/visual'
      end
      
      team = interface.get_team_for channel, team_name
      team.each do |member|
        client.reply(member, channel)
      end
    end
  end

  
end
