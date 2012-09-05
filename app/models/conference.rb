# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file
require 'csv'

class Conference < ActiveRecord::Base
  attr_accessible :name, :hashtag, :tagline, :description, :website, :start_date, :end_date, :creator, :last_modifier, :creator_id, :last_modifier_id, :time_zone, :is_virtual

  validates :name, :presence => true
  validates :hashtag, :uniqueness => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :website, :allow_blank => true, :uri => true

  has_many :conference_connections
  has_many :events
  has_many :presenters, :through => :events
  belongs_to :creator, :class_name => "Learner"
  belongs_to :last_modifier, :class_name => "Learner"
  has_many :evaluation_questions

  has_many :attendees, through: :conference_connections, source: :learner, conditions: ["conference_connections.connectiontype = ?", ConferenceConnection::ATTEND]
  scope :attended, include: :conference_connections, conditions: ["conference_connections.connectiontype = ?", ConferenceConnection::ATTEND]


  def self.find_by_id_or_hashtag(id,raise_not_found = true)
    # does the id contain a least one alpha? let's search by hashtag
    if(id =~ %r{[[:alpha:]]?})
      conference = self.find_by_hashtag(id)
    end

    if(!conference)
      conference = self.find_by_id(id)
    end

    if(!conference)
      if(raise_not_found)
        raise ActiveRecord::RecordNotFound
      else
        return nil
      end
    end

    conference
  end

  def grouped_events_for_date(date)
    grouped = {}
    list = self.events.by_date(date).order(:session_start)
    list.each do |e|
      grouped[e.session_start] ||= []
      grouped[e.session_start] << e
    end
    grouped
  end

  def event_date_counts
    self.events.group('DATE(session_start)').count
  end


  def in_progress?
    return (self.start_date <= Date.today) && (self.end_date >= Date.today)
  end

  def concluded?
    return !(self.end_date < Date.today)
  end

  def rooms
    self.events.pluck(:room).uniq.sort
  end

  def default_time
    if(self.events.count > 0)
      self.events.order(:session_start).limit(1).pluck(:session_start).first
    else
      current_tz = Time.zone
      Time.zone = self.time_zone
      returntime = Time.zone.parse("#{self.start_date} 08:00:00")
      Time.zone = current_tz
      returntime
    end
  end

  def default_length
    if(self.events.count > 0)
      self.events.order(:session_start).limit(1).pluck(:session_length).first
    else
      45
    end
  end
    # override timezone writer/reader
  # returns Eastern by default, use convert=false
  # when you need a timezone string that mysql can handle
  def time_zone(convert=true)
    tzinfo_time_zone_string = read_attribute(:time_zone)
    if(tzinfo_time_zone_string.blank?)
      tzinfo_time_zone_string = DEFAULT_TIMEZONE
    end

    if(convert)
      reverse_mappings = ActiveSupport::TimeZone::MAPPING.invert
      if(reverse_mappings[tzinfo_time_zone_string])
        reverse_mappings[tzinfo_time_zone_string]
      else
        nil
      end
    else
      tzinfo_time_zone_string
    end
  end

  def time_zone=(time_zone_string)
    mappings = ActiveSupport::TimeZone::MAPPING
    if(mappings[time_zone_string])
      write_attribute(:time_zone, mappings[time_zone_string])
    else
      write_attribute(:time_zone, nil)
    end
  end

  def import_sessions_from_csv_data(csv_data_string)
    create_data = {}
    create_data[:created_count] = 0
    create_data[:error_count] = 0
    create_data[:error_titles] = {}



    CSV.parse(csv_data_string) do |row|
      # expecting:
      # Title,Description,Presenters,Date,Time,Length,Room,Broadcast? (Yes/No),Location

      # ignore the title row 
      next if (row[0] =~ %r{^Title})

      event_attributes = {}
      event_attributes[:event_type] = Event::CONFERENCE
      event_attributes[:conference_id] = self.id
      event_attributes[:time_zone] = self.time_zone
      event_attributes[:creator] = Learner.learnbot
      event_attributes[:last_modifier] = Learner.learnbot


      event_attributes[:title] = row[0]
      event_attributes[:description] = (row[1].blank? ? 'TBD' : row[1])

      # presenters
      learner_list = []
      row[2].split(',').each do |presenter|
        name = presenter.strip
        if(learner = Learner.find_by_name(name))
          learner_list << learner
        end
      end
      event_attributes[:presenter_ids] = learner_list.map(&:id)

      begin
        event_date = Date.strptime(row[3], '%m/%d/%Y')
      rescue
        event_date = self.start_date
      end

      event_attributes[:session_start_string] = "#{event_date.strftime('%Y-%m-%d')} #{row[4]}"
      event_attributes[:session_length] = row[5]
      event_attributes[:room] = row[6]
      if(row[7].downcase == 'yes')
        event_attributes[:event_type] = Event::BROADCAST
      end

      if(!row[8].blank?)
        event_attributes[:location] = "#{row[8]}"
      else
        event_attributes[:location] = 'Conference Session'
      end

      if(event = Event.create(event_attributes) and event.valid?)
        create_data[:created_count] += 1
      else
        create_data[:error_count] += 1
        create_data[:error_titles][event_attributes[:title]] = event.errors.full_messages.join(' | ')
      end
    end
    create_data
  end




  
end