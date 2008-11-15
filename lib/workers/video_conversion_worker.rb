# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class VideoConversionWorker < BackgrounDRb::Rails
  
  require 'digest/sha1'
  
  attr_accessor :video_file, :video_id
  
  # This method is called in it's own new thread when you
  # call new worker. args is set to :args
  #
  def do_work(args)
    @video_file = args[:absolute_path]
    @video_id = args[:video_id].to_i
    @torrent_tracker = args[:torrent_tracker]
    unless RAILS_ENV == 'test'
      video_record = Video.find(@video_id) 
      video_record.processing_status = 1 #the_video.PROCESSING #ProcessingStatuses[:processing]
      video_record.save
    end  
    `nice -n +19 ffmpeg -i #{@video_file} -ss 00:00:05 -t 00:00:01 -vcodec mjpeg -vframes 1 -an -f rawvideo -s 180x136 #{@video_file}.small.jpg`
    `nice -n +19 ffmpeg -i #{@video_file} -ss 00:00:05 -t 00:00:01 -vcodec mjpeg -vframes 1 -an -f rawvideo -s 320x240 #{@video_file}.jpg`
    `nice -n +19 ffmpeg -i #{@video_file} -ab 64 -ar 22050 -b 500000 -r 25 -s 320x240 #{@video_file}.flv`
    `nice -n +19 ffmpeg2theora #{@video_file}`
    ogg_file = @video_file.chomp(File.extname(@video_file)) + ".ogg"
    `btmakemetafile.bittornado #{@torrent_tracker} #{ogg_file}`
    
    torrent = @video_file.chomp(File.extname(@video_file)) + ".ogg.torrent"
    torrent_worker = MiddleMan.get_worker(1)
    torrent_worker.add_torrent(torrent)
    
    unless RAILS_ENV == 'test'
      video_record.processing_status = 2 #SUCCESS #ProcessingStatuses[:success]
      video_record.media_size = File.size?(@video_file)
      video_record.save
      # blow out any cached versions of the video-related pages.
      FileUtils.rm "#{RAILS_ROOT}/public/system/cache/videos/#{@video_id}.html", :force => true   # never raises exception
      FileUtils.rm "#{RAILS_ROOT}/public/system/cache/featured_videos_json.html", :force => true   # never raises exception
    end
  end

end

