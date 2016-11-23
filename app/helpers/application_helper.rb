module ApplicationHelper
  def date_is_utc_beginning_of_day?(date)
    date.beginning_of_day == date
  end
end
