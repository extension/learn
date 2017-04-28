class SetLocationWebinarId < ActiveRecord::Migration
  def up
    Event.reset_column_information
    Event.find_each do |e|
      e.set_location_webinar_id
    end
  end
end
