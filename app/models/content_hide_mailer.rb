# Allows the site to automatically send emails to a given address for notification 
# purposes when content is moderated.
#
class ContentHideMailer < ActionMailer::Base

  # Sends an email to the moderation email list, notifying the list that a piece
  # of Content has been hidden.
  #
  def hide(content,reasons, user)
    setup_email
    @subject    = 'Content Hidden'
    @body      = {:content => content, :reasons => reasons, :user => get_user_login(user)}
  end
  
  # Sends an email to the moderation email list, notifying the list that a piece
  # of Content has been promoted.
  #
  def promote(content,reasons, user)
    setup_email
    @subject    = 'Content Promoted'
    @body      = {:content => content, :reasons => reasons, :user => get_user_login(user)}
  end  

  # Sends an email to the moderation email list, notifying the list that a piece
  # of Content has been unhidden.
  #  
  def unhide(content,reasons, user)
    setup_email    
    @subject    = 'Content Unhidden'
    @body       = {:content => content, :reasons => reasons, :user => get_user_login(user)}
  end  
  
  # Sends an email to the moderation email list, notifying the list that a piece
  # of Content has been reported by a user of the site.
  #  
  def report(content,reasons, user)
    setup_email    
    @subject    = 'Problem reported with content'
    @body      = {:content => content, :reasons => reasons, :user => get_user_login(user)}
  end  

  # Sends an email to the moderation email list, notifying the list that a comment
  # has been reported by a user of the site.
  #  
  def report_comment(comment, reasons, user)
    setup_email
    @subject    = 'Problem reported with comment'
    @body       = {:comment => comment, :reasons => reasons, :user => get_user_login(user)}
  end
  
  # Sends an email to the moderation email list, notifying the list that a comment
  # has been hidden.
  #  
  def hide_comment(comment, reasons, user)
    setup_email
    @subject    = 'Comment hidden'
    @body       = {:comment => comment, :reasons => reasons, :user => get_user_login(user)}
  end

  # Sends an email to the moderation email list, notifying the list that a comment
  # has been unhidden.
  #  
  def unhide_comment(comment, reasons, user)
    setup_email
    @subject    = 'Comment unhidden'
    @body       = {:comment => comment, :reasons => reasons, :user => get_user_login(user)}
  end  
  
  private 
  
  # Sets up emails with the proper recipients, from and sent_on date.
  #
  def setup_email
    @recipients = Hyperactive.moderation_email_recipients
    @from       = Hyperactive.moderation_email_from
    @sent_on    = Time.now
    @headers    = {}    
  end
  
  def get_user_login(user)
    if user.is_a? String
      user
    elsif user.is_a? User
      user.login
    else
      "Anonymous"
    end  
  end
  
end
