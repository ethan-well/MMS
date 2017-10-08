class SystemSettingsController < ApplicationController
  before_action :is_admin?

  def update
    system_setting = SystemSetting.first
    system_setting.update_attributes(params['change_info'].to_hash)
  end
end
