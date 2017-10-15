class InvitesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index]
  def index
    invitation_code = params[:invitation_code]
    redirect_to new_user_registration_path(invitation_code: invitation_code)
  end
end
