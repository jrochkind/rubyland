class AggregatorController < ApplicationController
  def index

  end

  protected

  def entries
    @entries ||= Entry.includes(:feed).order("datetime desc").where("updated_at > ?", 3.months.ago).limit(110)
  end
  helper_method :entries


end