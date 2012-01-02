module LearnersHelper
  # get what type of activities/actions a learner had with this event
  def get_activity_types(event)
    activity_array = []
    activity_array << 'presented' if @presented_event_ids.include?(event.id)
    activity_array << 'attended' if @attended_event_ids.include?(event.id)
    activity_array << 'watched'  if @watched_event_ids.include?(event.id)
    activity_array << 'bookmarked' if @bookmarked_event_ids.include?(event.id)
    activity_array << 'commented' if @commented_event_ids.include?(event.id)
    activity_array << 'rated' if @rated_event_ids.include?(event.id)
    activity_array << 'answered questions' if @answered_event_ids.include?(event.id)
    return activity_array.join(', ')
  end
end
