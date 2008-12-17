# A political group registered on the site.
#
# This class basically serves to provide contact information and also to 
# group all kinds of content so we can see what a group's up to.
#
class Collective < ActiveRecord::Base

  # Validations
  #
  validates_length_of :name, :maximum => 255
  validates_length_of :summary, :maximum => 1000
  validates_presence_of :name, :summary
  validates_uniqueness_of :name
  
  # Associations
  #
  named_scope :featured, :conditions => ['moderation_status = "featured" or moderation_status = "recently_changed"'], :order => 'moderation_status, updated_on desc', :limit => 5
  has_many :collective_memberships
  has_many :users, :through => :collective_memberships
  # has_many_polymorphs :collective_associatables, :from => [:videos, :events, :articles], :through => :collective_associations, :order => 'collective_associations.created_on DESC'
  has_many :external_feeds
  has_many :content
  has_many :articles, :order => "created_on DESC"
  has_many :events, :order => "content.date ASC"
  has_many :videos, :order => "created_on DESC"

  # Macros
  #
  acts_as_xapian(:texts => [:name, :summary])  
  has_friendly_id :name, :use_slug => true
  image_column  :image, 
                :versions => { :thumb => "c96x96", :small => "c32x32"},
                :extensions => ["gif", "png", "jpg"],
                :root_dir => File.join(RAILS_ROOT, "public", "system"),
                :web_root => "/system", 
                :store_dir => proc {|record, file| 
                                      if !record.created_on.nil?
                                        return record.created_on.strftime("group/image/%Y/%m/%d/") +  record.id.to_s
                                      else
                                        return Date.today.strftime("group/image/%Y/%m/%d/") +  record.id.to_s
                                      end
                                   }
   
  # Filters
  #                 
  before_destroy :delete_image
  before_update :delete_image_if_new_uploaded 
  before_save :set_moderation_status
  
  def set_moderation_status
    unless self.moderation_status == 'featured'
      self.moderation_status = 'recently_changed'
    end
  end
  
  # Recursively deletes the image and then the directory which the image
  # was stored in.
  #
  def delete_image
    if !self.image.nil? 
      FileUtils.remove_dir(image.store_dir) if File.exists?(image.store_dir)
    end
  end 
  
  
  # Recursively deletes the image and then the directory which the image
  # was stored in, if a new image was uploaded during this request.
  #
  def delete_image_if_new_uploaded
    if !self.image.nil? && self.image.new_file?
      FileUtils.remove_dir(image.store_dir) if File.exists?(image.store_dir)
    end
  end
  
  
  # Does this collective have articles?
  #
  def has_articles?
    !articles.empty?
  end
  
  # Does this collective have events?
  #
  def has_events?
    !events.empty?
  end
  
  # Does this collective have upcoming events?
  #
  def has_upcoming_events?
    !upcoming_events.empty?
  end
  
  # Does this collective have videos?
  #
  def has_videos?
    !videos.empty?
  end
  
  # Does this collective have any external feeds?
  #
  def has_feeds?
    !external_feeds.empty?
  end
  
  # Upcoming events for this collective.
  #
  def upcoming_events
    self.events.find(:all, :conditions => ['date > ?', DateTime.now])
  end
  
  # Checks to see whether a collective is associated with a given piece of content.
  #
  def includes_content?(content)
    self.content.include?(content)
  end
  
end
