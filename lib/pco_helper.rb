require_relative "../environment.rb"
require 'date'
require 'pco_api'
class PCOHelper
  def initialize
    @pco = PCO::API::new(basic_auth_token: PCO_APP_ID, 
                      basic_auth_secret: PCO_SECRET)
  end
  
  def get_all_plans
    service_type_ids = get_service_type_ids
    plans = []
    service_type_ids.each do |type_id|
      service_type_plans =  @pco.services.v2.service_types[type_id].plans.get['data']
      service_type_plans.each do |plan|
        plans << plan
      end
    end
    return plans
  end

  def get_service_type_ids
    service_types = @pco.services.v2.service_types.get['data']
    service_type_ids = []
    service_types.each do |type|
      service_type_ids << type['id']
    end
    return service_type_ids
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

  def get_future_plans
    plans = get_all_plans
    plans.select {|plan| Date.parse(plan['attributes']['dates']) >= Date.today}
  end
  
  def get_dates(new_plan_keys)
    new_dates = []
    new_plan_keys.each do |key|
      plan = @pco.services.v2.service_types[key[:service_type_id]].plans[key[:plan_id]].get['data']
      date = plan['attributes']['dates']
      parsed_date = Date.parse(date)
      month = Date::ABBR_MONTHNAMES[parsed_date.month].downcase
      #set suffix
      if !parsed_date.day.between?(11,19)
        case parsed_date.day
        when 1
          suf = "st"
        when 2
          suf = "nd"
        when 3
          suf = "rd"
        else
          suf = "th"
        end
      else
        suf = "th"
      end
      day = "#{parsed_date.day}#{suf}"
      year = parsed_date.year
      formatted_date = "#{month}#{day}#{year}"
      new_dates << formatted_date
    end
    new_dates.each do |date|
      puts date
    end
    return new_dates
  end

  def get_team_for date, team_name
    team = get_full_team_for_date date
    name = team_name
    team_ids = get_team_ids_for name
    filtered_team = []
    if name == 'volunteers'
      filtered_team = team
    else
      team.each do |member|
        if team_ids.include? member['relationships']['team']['data']['id']
          filtered_team << member
        end
      end
    end
    return filtered_team
  end

  def get_full_team_for_date date
    plan = get_plan_for_date date
    plan_id = plan['id']
    type_id = plan['relationships']['service_type']['data']['id']
    team = @pco.services.v2.service_types[type_id].plans[plan_id].team_members.get['data']
  end


  def get_team_ids_for name
    teams = get_all_teams
    filtered_teams = teams.select{|team| team['attributes']['name'].chomp.downcase == name}
    team_ids = []
    filtered_teams.each do |team|
      if !team_ids.include? team['id']
        team_ids << team['id']
      end
    end
    return team_ids
  end

  def get_all_teams
    service_type_ids = get_service_type_ids
    teams = []
    service_type_ids.each do |type_id|
      @pco.services.v2.service_types[type_id].teams.get['data'].each do |team|
        teams << team
      end
    end
    return teams
  end

end
