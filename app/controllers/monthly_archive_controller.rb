class MonthlyArchiveController < ApplicationController
  layout "two_column"

  def index
    @oldest_date = get_oldest_date()
    @oldest_date = Date.new(@oldest_date.year, @oldest_date.month, 1)
    @now = Date.today

   # @months = create_month_list @oldest_date, @now
    @month_count = create_month_count_list @oldest_date, @now
  end

  def year_index
    @year = params[:year].to_i
    @start_date = get_oldest_date()
    @start_date = Date.new(@start_date.year, @start_date.month, 1)
    @end_date = Date.today
    if @start_date.year < @year
      @start_date = Date.new(@year, 1, 1)
    end
    if @end_date.year > @year
      @end_date = Date.new(@year, 12, 1)
    end
    #@months = create_month_list @start_date, @end_date
    @month_count = create_month_count_list @start_date, @end_date
  end

  def month_index 
    @year = params[:year].to_i
    @month = params[:month].to_i
    
    @datestart = Date.new(@year, @month, 1)
    @dateend = Date.new(@year, @month, -1)

    @content = Content.find(:all,
    :conditions => ['moderation_status != ? and created_on >= ? and created_on <= ?', "hidden", @datestart, @dateend])
  end

  private

  def get_oldest_date
    @oldest_content = Content.find(:first,
          :conditions => ['moderation_status != ?', "hidden"],
          :order      => 'created_on')
    return @oldest_content.created_on
  end

  def create_month_list(start_date, end_date)
    months = []
    while end_date >= start_date
      months << end_date
      end_date = end_date << 1
    end
    return months
  end

  def create_month_count_list(start_date, end_date)
    months = create_month_list(start_date, end_date)
    month_count = []
    for month in months
      month_start = Date.new(month.year, month.month, 1)
      month_end = Date.new(month.year, month.month, -1)
      count = Content.count(:conditions => ['moderation_status != ? and created_on >= ? and created_on <= ?', 
                            "hidden", month_start, month_end])
      month_count << {:month => month, :count => count}
    end
    return month_count
  end
end
