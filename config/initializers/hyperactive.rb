# Some general configuration stuff
#
Hyperactive.banner_image = "banner.png"
Hyperactive.show_site_name_in_banner = false
Hyperactive.use_ssl = true

# Email configuration
# 
# What address should hide/unhide/inappropriate content notifications be sent to?
#
Hyperactive.moderation_email_recipients = 'imc-london-moderation@lists.indymedia.org'

# Who should moderation emails originate from?
#
Hyperactive.moderation_email_from = "indy site <site@london.indymedia.org.uk>"

require 'tag_extensions'
require 'vpim/icalendar'

ActiveRbac.controller_layout = "admin" 
ActiveRecord::Base.verification_timeout = 14400

ROUTES_PROTOCOL = (ENV["RAILS_ENV"] =~ /development/ ? "http://" : "https://")