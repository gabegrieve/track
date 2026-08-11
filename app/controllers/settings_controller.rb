class SettingsController < ApplicationController
  def show
    @business_setting = business_setting
  end

  def update
    @business_setting = business_setting
    if @business_setting.update(setting_params)
      redirect_to settings_path, notice: "Business settings saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.require(:business_setting).permit(:business_name, :business_address, :abn, :email, :payment_instructions, :gst_rate)
  end
end
