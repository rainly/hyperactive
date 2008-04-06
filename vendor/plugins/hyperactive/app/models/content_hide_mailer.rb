class ContentHideMailer < ActionMailer::Base

  def hide(content,reasons, user)
    setup_email
    @subject    = 'Content Hidden'
    @body      = {:content => content, :reasons => reasons, :user => user}
  end
  
  def report(content,reasons, user)
    setup_email    
    @subject    = 'Problem reported with content'
    @body      = {:content => content, :reasons => reasons, :user => user}
  end  
  
  def unhide(content,reasons, user)
    setup_email    
    @subject    = 'Content Unhidden'
    @body       = {:content => content, :reasons => reasons, :user => user}
  end
  
  private 
  
  def setup_email
    @recipients = 'yossarian@aktivix.org'
    @from       = "indy site <site@ny.indymedia.dk>"
    @sent_on    = Time.now
    @headers    = {}    
  end
end
