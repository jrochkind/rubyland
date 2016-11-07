class AggregatorController < ApplicationController
  def index

  end

  protected

  def entries
    # start_of_day keeps our condition from changing every second,
    # for cacheability. 
    earliest_time = Time.now.utc.beginning_of_day - 3.months
    @entries ||= Entry.includes(:feed).order("datetime desc").where("updated_at > ?", earliest_time).limit(110)
  end
  helper_method :entries

  def titles_only?
    !! params[:titles_only]
  end
  helper_method :titles_only?

end