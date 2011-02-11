require 'checks/base_check'

#Checks that +protect_from_forgery+ is set in the ApplicationController.
#
#Also warns for CSRF weakness in certain versions of Rails:
#http://groups.google.com/group/rubyonrails-security/browse_thread/thread/2d95a3cc23e03665
class CheckForgerySetting < BaseCheck
  Checks.add self

  def run_check
    app_controller = tracker.controllers[:ApplicationController]
    if tracker.config[:rails][:action_controller] and
      tracker.config[:rails][:action_controller][:allow_forgery_protection] == Sexp.new(:false)

      warn :controller => :ApplicationController,
        :warning_type => "Cross Site Request Forgery",
        :message => "Forgery protection is disabled", 
        :confidence => CONFIDENCE[:high]

    elsif app_controller and not app_controller[:options][:protect_from_forgery]

      warn :controller => :ApplicationController, 
        :warning_type => "Cross-Site Request Forgery", 
        :message => "'protect_from_forgery' should be called in ApplicationController", 
        :confidence => CONFIDENCE[:high]

    elsif version_between? "2.1.0", "2.3.10"
      
      warn :controller => :ApplicationController, 
        :warning_type => "Cross-Site Request Forgery",
        :message => "CSRF protection is flawed in #{tracker.config[:rails_version]} (CVE-2011-0447). Upgrade to 2.3.11 or apply patches",
        :confidence => CONFIDENCE[:high]

    elsif version_between? "3.0.0", "3.0.3"

      warn :controller => :ApplicationController, 
        :warning_type => "Cross-Site Request Forgery",
        :message => "CSRF protection is flawed in #{tracker.config[:rails_version]} (CVE-2011-0447). Upgrade to 3.0.4",
        :confidence => CONFIDENCE[:high]
    end
  end
end
