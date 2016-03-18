class Interface
  require_relative '../environment.rb'
  require 'pco_api'
  require 'date'
  



  def initialize
    @pco = PCO::API::new(basic_auth_token: PCO_APP_ID, 
                        basic_auth_secret: PCO_SECRET)
    @slack_token = SLACK_API_TOKEN
  end

  #interface methods
  def get_band_list_for channel_id
    band_list = []
    channel_name = get_channel_name_for channel_id
    month_names = []
    Date::ABBR_MONTHNAMES[1..12].each do |month|
      month_names << month.downcase
    end
    if month_names.include? channel_name.strip[0,3]
      #parse the date based on the channel name
      date = Date.parse(channel_name)
      plan = get_plan_for_date date
      plan_id = plan['id']
      type_id = plan['relationships']['service_type']['data']['id']
      band = @pco.services.v2.service_types[type_id].plans[plan_id].team_members.get['data']
      band.each do |member|
        name = member['attributes']['name']
        position = member['attributes']['team_position_name']
        band_list << "#{name} --- #{position}"
      end
    end
    return band_list
  end

  #pco methods
  def get_all_plans
    service_types = @pco.services.v2.service_types.get['data']
    service_type_ids = []
    service_types.each do |type|
      service_type_ids << type['id']
    end
    plans = []
    service_type_ids.each do |type_id|
      service_type_plans =  @pco.services.v2.service_types[type_id].plans.get['data']
      service_type_plans.each do |plan|
        plans << plan
      end
    end
    return plans
  end
  
  def get_plan_for_date date
    plans = get_all_plans
    plan_list = plans.select {|plan| Date.parse(plan['attributes']['dates']) == date}
    if plan_list.empty?
      return nil
    else
      return plan_list[0]
    end
  end

  #slack methods
  def get_channel_name_for(channel_id)
    response = open('https://slack.com/api/channels.info?token=' + 
                    @slack_token + '&channel=' + channel_id+ '&pretty=1').read
    channel_info = JSON.parse(response)
    channel_info['channel']['name']

  end

  #def self.get_date_for(channel_id)
  # channel = $rtm['channels'].select {|channel| channel['id'] == channel_id} 
  # channel_name = channel[0]['name']
  # puts channel_name
  # Date.parse(channel_name)
  #end

  #def self.get_band_list(date)

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

end
