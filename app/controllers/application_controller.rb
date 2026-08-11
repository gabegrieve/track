class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :business_setting

  private

  def business_setting
    @business_setting ||= BusinessSetting.current
  end
end
