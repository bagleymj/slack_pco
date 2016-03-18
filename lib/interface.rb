class Interface
  require_relative '../environment.rb'
  require_relative './pco_helper.rb'
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
      pco = PCOHelper.new
      plan = pco.get_plan_for_date date
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

  #slack methods
  def get_channel_name_for(channel_id)
    response = open('https://slack.com/api/channels.info?token=' + 
                    @slack_token + '&channel=' + channel_id+ '&pretty=1').read
    channel_info = JSON.parse(response)
    channel_info['channel']['name']

  end

end
