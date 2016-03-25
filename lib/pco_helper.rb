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

  def get_team_for date, team_name
    team = get_full_team_for_date date
    name = team_name
    team_ids = get_team_ids_for name
    filtered_team = []
    if name = 'volunteers'
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
    service_type_ids = get_service_type_ids
    teams = []
    service_type_ids.each do |type_id|
      @pco.services.v2.service_types[type_id].teams.get['data'].each do |team|
        teams << team
      end
    end
    filtered_teams = teams.select{|team| team['attributes']['name'].chomp.downcase == name}
    team_ids = []
    filtered_teams.each do |team|
      if !team_ids.include? team['id']
        team_ids << team['id']
      end
    end
    return team_ids
      
  end

end
