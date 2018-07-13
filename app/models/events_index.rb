# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file


class EventsIndex < Chewy::Index
  define_type Event do
    field :session_start, type: 'date'
    field :title, type: 'text', term_vector: 'yes'
    field :description, type: 'text', term_vector: 'yes'
    field :tag_list, type: 'text'
    field :presenter_names, type: 'text'
    field :is_canceled, type: 'boolean'
    field :is_expired, type: 'boolean'
    field :is_deleted, type: 'boolean'
  end

  def self.not_canceled_or_deleted
    query(match: {is_canceled: false}).query(match: {is_deleted: false})
  end

  def self.globalsearch(searchquery)
    query(multi_match: {
          query: searchquery,
          fields: [
            :title,
            :description,
            :taglist,
            :presenter_names
          ]
      }
    )
  end

  def self.similar_to_event(event)
    query(
      more_like_this: {
          fields: [
            :title,
            :description
          ],
          like: [
            {
              "_index" => self.index_name,
              "_type" => EventsIndex::Event.type_name,
              "_id" => "#{event.id}"
            }
          ],
          min_term_freq: 2,
          max_query_terms: 25
        }
    ).order("_score")
  end


end
