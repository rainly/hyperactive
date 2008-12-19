class Admin::BackgroundRbStatusController < ApplicationController
  
  before_filter :protect_controller
  layout "admin"
  
  def index
  end

  def restart
   `cd #{RAILS_ROOT} && RAILS_ENV=#{RAILS_ENV} #{RAKE_PATH} backgroundrb:restart`    
  end

  def stop
   `cd #{RAILS_ROOT} && RAILS_ENV=#{RAILS_ENV} #{RAKE_PATH} backgroundrb:stop` 
  end

  def start
   `cd #{RAILS_ROOT} && RAILS_ENV=#{RAILS_ENV} #{RAKE_PATH} backgroundrb:start`
  end
 
  def get_status
    begin
      @status = MiddleMan.get_worker(:auto_moderation).status
    rescue
      @status = "not running.  You should start it."
    end    
  end

  protected
  
  def protect_controller
    if current_user.has_role?("Admin")
      return true
    else
      security_error
    end
  end  

end
