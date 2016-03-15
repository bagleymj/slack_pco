class Bot
  require_relative '../environment.rb'
  require 'pco_api'
  require 'open-uri'
  require 'json'
  require 'websocket-client-simple'
  require 'date'

  def self.get_date_for(channel_id)
   channel = $rtm['channels'].select {|channel| channel['id'] == channel_id} 
   channel_name = channel[0]['name']
   puts channel_name
   Date.parse(channel_name)
  end

  def self.get_band_list(date)
    @pco = PCO::API::new(basic_auth_token: PCO_APP_ID, 
                        basic_auth_secret: PCO_SECRET)

    service_types = @pco.services.v2.service_types.get['data']
    service_type_ids = []
    service_types.each do |type|
      service_type_ids << type['id']
    end

    plan_id = nil

    band_list = []
    service_type_ids.each do |type_id|
      plans = @pco.services.v2.service_types[type_id].plans.get['data']
      puts "Check for service on #{date.month}/#{date.day}/#{date.year}"
      plan = plans.select {|plan| Date.parse(plan['attributes']['dates']) == date}
      plan_date = Date.parse(plan[0]['attributes']['dates'])
      puts "Found #{plan_date.month}/#{plan_date.day}/#{plan_date.year}"
      plan_id = plan[0]['id']
      band = @pco.services.v2.service_types[type_id].plans[plan_id].team_members.get['data']
      band.each do |member|
        puts member
        name = member['attributes']['name']
        position = member ['attributes']['team_position_name']
        band_list << "#{name} --- #{position}"
      end
    end
    return band_list
  end

  def self.get_new_session
    bot_token = SLACK_BOT_TOKEN
    response = open('https://slack.com/api/rtm.start?token='+ bot_token + '&pretty=1').read
    return response
  end
  
  response = get_new_session

  $rtm = JSON.parse(response)

  url = $rtm['url']


  # let's get chatty
  i = 0
  connection_count = 0
  ws = nil
  time_up = false
  threads = []
  threads << Thread.new {
    ws = WebSocket::Client::Simple.connect url

    ws.on :open do 
      if connection_count == 0
        puts "\n\nCONNECTED!"
        puts "\n\nTo exit simply type 'exit' in the console and press ENTER."
        connection_count += 1
      end
    end

    ws.on :error do |e|
      p e
    end

    ws.on :message do |msg|
      msg = msg.to_s
      message = JSON.parse(msg)
      type = message['type']
      if type == "message"
        channel_id = message['channel']
        text = message['text']
        if text.strip.downcase == "band"
          date = Bot.get_date_for channel_id
          band_list = Bot.get_band_list(date)
          band_list.each do |member|
            i += 1
            response = {id: i, type: 'message', channel: channel_id, text: member}.to_json
            ws.send response
          end
        end
      end
      
    end

    ws.on :close do

      #puts "Connection Closed. Goodbye!"
    end

    loop do
      msg = gets.chomp.downcase
      if msg == "exit"
        ws.close
        break
      end
      #if msg == "url"
      #  puts ws.url
      #end
    end
  }
  threads << Thread.new {
    loop do
      sleep 25
      #puts "Changing connection in 5 secconds"
      if !ws.open?
        puts "Lost connection...reconnecting"
      end
      sleep 5
      new_session = get_new_session
      rtm = JSON.parse(new_session)
      new_url = rtm['url']
      ws.close
      ws.connect new_url   
      if new_url != ws.url
        puts "Connection refresh error!"
      end
    end
  }

  threads.each do |thread|
    thread.join
  end

end
