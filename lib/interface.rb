class Interface
  require_relative '../environment.rb'
  require_relative './pco_helper.rb'
  require 'pco_api'
  require 'date'
  
  def initialize
    @pco = PCOHelper.new
    @slack_token = SLACK_API_TOKEN
  end

  #interface methods
  def get_band_list_for channel_id
    band_list = []
    channel_name = get_channel_name_for channel_id
    if is_date? channel_name
      #parse the date based on the channel name
      date = Date.parse(channel_name)
      band = @pco.get_band_for_date date
      band.each do |member|
        name = member['attributes']['name']
        position = member['attributes']['team_position_name']
        status = member['attributes']['status']
        entry = "#{name} --- #{position}"
        case status
        when "U"
          formatted_entry = "_#{entry}_"
        when "D"
          formatted_entry = "~#{entry}~"
        when "C"
          formatted_entry = entry
        end
        
        
        band_list << formatted_entry
      end
    end
    return band_list
  end
  def get_team_list_for channel_id
    # One method to handle all scopes

  end

  #pco methods

  #slack methods
  def get_channel_name_for(channel_id)
    response = open('https://slack.com/api/channels.info?token=' + 
                    @slack_token + '&channel=' + channel_id+ '&pretty=1').read
    channel_info = JSON.parse(response)
    channel_info['channel']['name']

  end

  def is_date?(channel_name)
    month_names = []
    Date::ABBR_MONTHNAMES[1..12].each do |month|
      month_names << month.downcase
    end
    month_names.include? channel_name.strip[0,3]
  end

end
