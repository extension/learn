class AddMflnFlag < ActiveRecord::Migration
  def up
    add_column(:events, :is_mfln, :boolean, :default => false)
    Event.reset_column_information
    Event.tagged_with('militaryfamilies').each do |e|
      e.update_column(:is_mfln,true)
    end
  end
end
