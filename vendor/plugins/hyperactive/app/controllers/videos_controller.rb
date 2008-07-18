class VideosController < ContentController
  
  layout "two_column"
  
  # Rails does not pull out single-table inheritance subclasses properly on its own.
  # Must require the STI superclass explicitly in controllers.
  require_dependency 'content'    
  require_dependency 'media'
  
  caches_page :featured_in_player
  cache_sweeper :videos_sweeper, :only => [:create, :update, :destroy]  
  
  def show
    @previous_videos = Video.find(:all, :conditions => ['moderation_status = ? and id != ?', "published", params[:id]], :limit => 5, :order => 'created_on DESC')
    @featured_videos = Video.find_where(:all, :order => 'created_on ASC', :limit => 5) do |video|
      video.processing_status == 2
      video.moderation_status == "published"
    end
    super
  end
  
  def create
    @content = Video.new(params[:content])  
    respond_to do |format|
      if (!current_user.is_anonymous? || simple_captcha_valid?) && @content.save
        @content.tag_with params[:tags]
        @content.place_tag_with params[:place_tags]
        do_video_conversion 
        flash[:notice] = "Video was successfully created."
        format.html { redirect_to video_url(@content) }
        format.xml  { head :created, :location => video_url(@content) }
      else
        format.html { 
          @content.errors.add_to_base("You need to type the text from the image into the box so we know you're not a spambot.") unless (simple_captcha_valid?)
          render :action => "new" 
        }
        format.xml  { render :xml => @content.errors.to_xml }
      end
    end    
  end
  
  def update
    @content = model_class.find(params[:id])
    @content.update_attributes(params[:content])
    respond_to do |format|
      if @content.save
        @content.tag_with params[:tags]
        @content.place_tag_with params[:place_tags]
        do_video_conversion
        flash[:notice] = "Video was successfully updated."
        format.html { redirect_to video_url(@content) }
        format.xml  { head :created, :location => video_url(@content) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content.errors.to_xml }
      end
    end    
  end  
    
  def featured_in_player
    videos = Video.find_where(:all, :limit => 3, :order => 'created_on DESC') do |video|
      video.moderation_status == "promoted"
      video.processing_status == 2
    end
    featured_vids = []
    videos.each do |video|
      featured_video = VideoSummary.new
      featured_video.title = video.title
      featured_video.id = video.id
      featured_video.file_path = video.file.url + '.small.jpg' #"/system/video/file/#{video.file_relative_path}.small.jpg"
      featured_vids << featured_video
    end
    respond_to do |format|
      format.json {render :text => "vids=#{featured_vids.to_json}"}
    end
  end
  
  protected
  
  def model_class
    Video
  end
  
  def find_videos_needing_conversion
    videos_needing_conversion = []
    uploaded_video = params[:content][:file]
    if uploaded_video.class != StringIO && uploaded_video.class != String
      videos_needing_conversion << @content
    end
    return videos_needing_conversion
  end
    
end
