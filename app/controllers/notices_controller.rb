class NoticesController < ApplicationController
  before_action :is_admin?

  def update
    notice = Notice.find(params['id'])
    result = notice.update_attribute(:content, params['content'])

    render json: { result: result }
  end
end
