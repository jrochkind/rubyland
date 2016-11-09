module ApplicationHelper
  def date_is_utc_beginning_of_day?(date)
    date.beginning_of_day == date
  end

  def on_titles_only_feed?
    params[:controller] == "aggregator" && !!params[:titles_only]
  end

end
