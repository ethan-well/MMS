class SystemSettingsController < ApplicationController
  before_action :is_admin?

  def update
    system_setting = SystemSetting.first
    puts params['change_info']
    system_setting.update_attributes(params['change_info'].to_hash)
  end
end
