require_relative 'application_controller'

class ActivityLogsController < ApplicationController
  def index
    # Fetch logs with user association
    @logs = ActivityLog.order(Sequel.desc(:created_at)).limit(100).all
    render 'cms/activity_logs'
  end
end
