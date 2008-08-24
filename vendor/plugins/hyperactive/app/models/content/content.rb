class Content < ActiveRecord::Base
    
  set_table_name "content"
  acts_as_ferret({:fields => [:title, :body, :summary, :place, :published_by, :date], :remote => true } )      
  before_create :set_moderation_status_to_published
  has_many :comments
  has_many :published_comments, :class_name => "Comment", :conditions => "moderation_status = 'published'"
  validates_length_of :title, :maximum => 50
  validates_presence_of :title, :summary, :published_by
  
  after_save :save_assigned_collectives
  
  # A convenience method to tell us whether this content is attached to 
  # an article or event.  Currently this should only ever return true for
  # Video, which is the only Content subtype that can be contained by
  # another piece of content. 
  #
  def has_related_content?
    self.respond_to?(:content) && !self.content.nil?
  end
      
  def has_comments?
    self.comments.length > 0
  end
  
  def allows_comments?
    self.allows_comments
  end
  
  # A convenience method telling us whether this content has a thumbnail
  # which we can use in a view.
  #
  def has_thumbnail?
    self.photos.length > 0 || self.videos.length > 0
  end
  
  def is_hidden?
    self.moderation_status == "hidden"  
  end

  def is_published?
    self.moderation_status == "published"
  end
  
  def is_promoted?
    self.moderation_status == "promoted"
  end
  
  def is_not_hidden?
    self.moderation_status != "hidden"
  end
  
  def is_collectivized?
    !self.collectives.empty?
  end

  # Sets up an instance variable so we can save the association in an after_save filter.
  #
  def collective_ids=(ids)
    @new_collective_ids = ids
  end
  
  # Creates or destroys the associations between this content and whatever collectives it's 
  # grouped within.  Called from an after_save filter.
  # 
  def save_assigned_collectives
    collective_associations.each do |collective_association|
      collective_association.destroy unless @new_collective_ids.to_a.include? collective_association.collective_id
    end
   
    @new_collective_ids.to_a.each do |id|
      self.collective_associations.create(:collective_id => id) unless collective_associations.any? { |d| d.collective_id == id }
    end
  end

#  This doesn't do anything yet but might when we move towards getting the 
#  content archives cacheable.
#  
#  def date_path
#    self.created_on.strftime("%Y/%m/%d")
#  end
  
  protected
  
  # Sets the moderation_status to published unless it's already been set, 
  # which could happen if an admin user set it during content creation.
  def set_moderation_status_to_published
    self.moderation_status = "published" if self.moderation_status.blank?
  end
  
end