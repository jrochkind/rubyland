module ApplicationHelper
  def date_is_utc_beginning_of_day?(date)
    date.beginning_of_day == date
  end

  def on_feed_entries_page?
    params[:controller] == "aggregator" && params[:action] == "index"
  end

end
