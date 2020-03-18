class ApplicationController < ActionController::Base

  private

  def user_not_authorized
    render :file => "public/401.html", :status => :unauthorized
  end
end
