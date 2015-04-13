class VisitorsController < ApplicationController

  def index
    stories_for_day Date.today
    next_prev
  end
end
