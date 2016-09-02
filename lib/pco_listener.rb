class PCOListener
  require_relative '../environment.rb'
  require './interface.rb'
  require './pco_helper'
  require 'pco_api'
  require 'date'
  require 'open-uri'

  def initialize
    @pco = PCO::API::new(basic_auth_token: PCO_APP_ID, 
                      basic_auth_secret: PCO_SECRET)
    @pco_helper = PCOHelper.new
    listen
  end

    

  def get_plan_count(service_type_ids)
    #initial plan count
    plan_count = 0
    service_type_ids.each do |type|
      plans = @pco.services.v2.service_types[type].plans.get(filter: "future")['data']
      plans.each do |plan|
        plan_count += 1
      end
    end
    return plan_count
  end

  def get_plan_keys(service_type_ids)
    plan_keys = []
    service_type_ids.each do |type|
      plans = @pco.services.v2.service_types[type].plans.get(filter: "future")['data']
      plans.each do |plan|
        plan_keys << {service_type_id: type, plan_id: plan['id']}
      end
    end
    return plan_keys
  end

  def create_channels_for(dates)
    dates.each do |date|
      resp = open('https://slack.com/api/channels.create?token=' + SLACK_API_TOKEN + '&name='+ date + '&pretty=1')
      puts resp
    end
  end


  def listen
    puts "Launching PCO Listener"
    service_type_ids = []
    service_types = @pco.services.v2.service_types.get['data']
    service_types.each do |type|
      service_type_ids << type['id']
    end 



    prev_plan_count = get_plan_count(service_type_ids)
    prev_plan_keys = get_plan_keys(service_type_ids)

    loop do
      #listen for new plans
      current_plan_count = get_plan_count(service_type_ids)
      puts "Was " + prev_plan_count.to_s
      puts "Now " + current_plan_count.to_s
      if current_plan_count > prev_plan_count
        puts "Adding plan to Slack"
        plan_keys = get_plan_keys(service_type_ids)
        new_plan_keys = []
        plan_keys.each do |plan_key|
          if !prev_plan_keys.include? plan_key
            new_plan_keys << plan_key
          end
        end
        dates = @pco_helper.get_dates(new_plan_keys)
        create_channels_for dates
        prev_plan_count = current_plan_count
        prev_plan_keys = plan_keys
      end
      sleep 5
    end
  end
end
