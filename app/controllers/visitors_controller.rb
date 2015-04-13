class VisitorsController < ApplicationController

  def index
    @headlines = Story.where(["day = ? and month = ? and image is not null and feature = true",Date.today.day, Date.today.month])
    @sublines = Story.where(["day = ? and month = ? and image is not null and feature = false",Date.today.day, Date.today.month])
    @other_olds = Story.where(["day = ? and month = ? and image is null",Date.today.day, Date.today.month])
    next_prev
  end
end
