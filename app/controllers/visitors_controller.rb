class VisitorsController < ApplicationController

  def index
    @headlines = Story.where(["day = ? and month = ? and image is not null",Date.today.day, Date.today.month])
    @sublines = Story.where(["day = ? and month = ? and image is null",Date.today.day, Date.today.month])
  end
end
