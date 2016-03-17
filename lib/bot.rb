class Bot
  require_relative '../environment.rb'
  require_relative './slack_client.rb'
  require 'pco_api'
  require 'open-uri'
  require 'json'
  require 'websocket-client-simple'
  require 'date'


  #def self.get_date_for(channel_id)
  # channel = $rtm['channels'].select {|channel| channel['id'] == channel_id} 
  # channel_name = channel[0]['name']
  # puts channel_name
  # Date.parse(channel_name)
  #end

  #def self.get_band_list(date)
  #  @pco = PCO::API::new(basic_auth_token: PCO_APP_ID, 
  #                      basic_auth_secret: PCO_SECRET)

  #  service_types = @pco.services.v2.service_types.get['data']
  #  service_type_ids = []
  #  service_types.each do |type|
  #    service_type_ids << type['id']
  #  end

  #  plan_id = nil

  #  band_list = []
  #  service_type_ids.each do |type_id|
  #    plans = @pco.services.v2.service_types[type_id].plans.get['data']
  #    puts "Check for service on #{date.month}/#{date.day}/#{date.year}"
  #    plan = plans.select {|plan| Date.parse(plan['attributes']['dates']) == date}
  #    plan_date = Date.parse(plan[0]['attributes']['dates'])
  #    puts "Found #{plan_date.month}/#{plan_date.day}/#{plan_date.year}"
  #    plan_id = plan[0]['id']
  #    band = @pco.services.v2.service_types[type_id].plans[plan_id].team_members.get['data']
  #    band.each do |member|
  #      name = member['attributes']['name']
  #      position = member ['attributes']['team_position_name']
  #      band_list << "#{name} --- #{position}"
  #    end
  #  end
  #  band_list.each do |entry|
  #    puts entry
  #  end
  #  return band_list
  #end

  def get_client
    slack_client = SlackClient.new
    client = slack_client.connect
    return client
  end

  def get_message(message_text, client)
    bot_words = ['band']
    if bot_words.include? message_text
      reply_text = "This is my reply"
      puts "I hear ya!"
      client.reply(reply_text)
    else
      puts "Don't quite understand"
    end
  end

  
end
