class Devise::SmsActivationsController < DeviseController

  # GET /resource/sms_activation/new
  def new
    build_resource({})
    render :new
  end

  # POST /resource/sms_activation
  def create
    self.resource = resource_class.send_sms_token(params[resource_name])
    if resource.errors.empty?
      set_flash_message :notice, :send_token, :phone => self.resource.phone
      redirect_to new_session_path(resource_name)
    else
      set_flash_message(:error, :already_confirmed) if self.resource.confirmed_sms?
      render :new
    end
  end
  
  # GET /resource/sms_activation/insert
  def insert
    build_resource({})
  end
  
  # GET or POST /resource/sms_activation/consume?sms_token=abcdef
  def consume
    self.resource = resource_class.confirm_by_sms_token(params[:sms_token] || params[resource_name][:sms_token])
    if resource.errors.empty?
      set_flash_message(:notice, :confirmed)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      render :new
    end
  end
  
  protected
  
    def build_resource(hash = nil)
      self.resource = resource_class.new
    end

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    if signed_in?(resource_name)
      signed_in_root_path(resource)
    else
      new_session_path(resource_name)
    end
  end

end
