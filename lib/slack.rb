class Stack
  require '../environment.rb'
  require 'pco_api'
  require 'date'
  require 'open-uri'

  @pco = PCO::API::new(basic_auth_token: PCO_APP_ID, 
                      basic_auth_secret: PCO_SECRET)

    

  def get_plan_count(service_type_ids)
    #initial plan count
    plan_count = 0
    service_type_ids.each do |type|
      plans = @pco.services.v2.service_types[type].plans.get['data']
      plans.each do |plan|
        plan_count += 1
      end
    end
    return plan_count
  end

  def get_plan_ids(service_type_ids)
    plan_ids = []
    service_type_ids.each do |type|
      plans = @pco.services.v2.service_types[type].plans.get['data']
      plans.each do |plan|
        plan_ids << plan['id']
      end
    end
    return plan_ids
  end

  def get_dates(service_type_ids, new_plan_ids)
    new_dates = []
    service_type_ids.each do |type_id|
      new_plan_ids.each do |plan_id|
        plan = @pco.services.v2.service_types[type_id].plans[plan_id].get['data']
        date = plan['attributes']['dates']
        parsed_date = Date.parse(date)
        month = Date::ABBR_MONTHNAMES[parsed_date.month].downcase
        day = "#{parsed_date.day}th"
        year = parsed_date.year
        formatted_date = "#{month}#{day}#{year}"
        new_dates << formatted_date
      end
    end
    new_dates.each do |date|
      puts date
    end
    return new_dates
  end

  def create_channels_for(dates)
    dates.each do |date|
      resp = open('https://slack.com/api/channels.create?token=xoxp-24886241922-24886396823-26639668375-4904edc63a&name='+ date + '&pretty=1')
    end
  end
  
  puts "Launching PCO Listener"
  service_type_ids = []
  service_types = @pco.services.v2.service_types.get['data']
  service_types.each do |type|
    service_type_ids << type['id']
  end 



  prev_plan_count = get_plan_count(service_type_ids)
  prev_plan_ids = get_plan_ids(service_type_ids)

  until 1 == 2
    current_plan_count = get_plan_count(service_type_ids)
    if current_plan_count > prev_plan_count
      plan_ids = get_plan_ids(service_type_ids)
      new_plan_ids = []
      plan_ids.each do |plan_id|
        if !prev_plan_ids.include? plan_id
          new_plan_ids << plan_id
        end
      end
      dates = get_dates(service_type_ids, new_plan_ids)
      create_channels_for dates
      prev_plan_count = current_plan_count
      prev_plan_ids = plan_ids
    else
      puts "No new plans. Current:#{prev_plan_count} Previous:#{current_plan_count}"
    end
    sleep 5
  end
end
