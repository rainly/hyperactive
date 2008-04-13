class Comment < ActiveRecord::Base
  
  belongs_to :content
  
  validates_presence_of :title, :body, :published_by
  
  before_create :set_moderation_status_to_published
  
  def set_moderation_status_to_published
    self.moderation_status = "published"
  end
  
end