class AggregatorController < ApplicationController
  def index

  end

  protected

  def entries
    @entries ||= Entry.includes(:feed).order("datetime desc").all
  end
  helper_method :entries


end