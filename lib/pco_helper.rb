require_relative "../environment.rb"
class PCOHelper
  def initialize
    @pco = PCO::API::new(basic_auth_token: PCO_APP_ID, 
                      basic_auth_secret: PCO_SECRET)
  end
  
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

  def get_band_list_for_date date
    band_list = []
    plan = get_plan_for_date date
    plan_id = plan['id']
    type_id = plan['relationships']['service_type']['data']['id']
    band = @pco.services.v2.service_types[type_id].plans[plan_id].team_members.get['data']
    band.each do |member|
      name = member['attributes']['name']
      position = member['attributes']['team_position_name']
      band_list << "#{name} --- #{position}"
    end
    return band_list
  end

end
