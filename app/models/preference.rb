# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Preference < ActiveRecord::Base
  belongs_to :prefable, :polymorphic => true
  before_save :set_datatype
  before_save :set_group_if_nil
  
  TRUE_PARAMETER_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'yes','YES'].to_set
  FALSE_PARAMETER_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE','no','NO'].to_set
  
  # convenience constants
  PREFERENCE_DEFAULTS = { 
   'notification.reminder.email' => true,
   'notification.reminder.sms' => false,
   'notification.reminder.sms.notice' => 15.minutes,  # seconds
   'notification.activity' => true,
   'notification.recording' => true,
   'notification.recommendation' => true,
   'sharing.events.presented' => true,
   'sharing.events.attended' => true,
   'sharing.events.watched' => true,
   'sharing.events.bookmarked' => true,
   #'sharing.events.commented' => true,
   'sharing.events.rated' => false,
   'sharing.events.answered' => false,
   'sharing.portfolio' => false
  }
  
  def set_datatype
    if(self.value.nil?)
      self.datatype = nil
    elsif(self.value.class.name == 'TrueClass' or self.value.class.name == 'FalseClass')
      self.datatype = 'Boolean'
    else
      self.datatype = self.value.class.name
    end
  end
  
  def set_group_if_nil
    if(self.group.nil?)
      if(%r{(?<groupname>\w+).(\w+)} =~ self.name)
        self.group = groupname
      end
    end
  end
  
  def value
    dbvalue = read_attribute(:value)
    if(!dbvalue.nil?)
      case self.datatype
      when 'Boolean'
        TRUE_PARAMETER_VALUES.include?(dbvalue)  
      when 'FixNum'
        dbvalue.to_i
      when 'String'
        dbvalue
      else 
        dbvalue
      end
    else
      nil
    end
  end      
  
  def self.setting(name)
    if(setting = where(name: name).first)
      setting.value
    else
      self.get_default(name)
    end
  end
  
  def self.settingsgroup(group)
    where(group: group)
  end
  
  def self.get_default(name)
    if(PREFERENCE_DEFAULTS[name])
      PREFERENCE_DEFAULTS[name]
    else
      nil
    end
  end
    
  def self.create_or_update(prefable,name,value)
    if(preference = where(prefable_id: prefable.id).where(prefable_type: prefable.class.name).where(name: name).first)
      preference.update_attribute(:value, value)
      # handle notification settings if notification.reminder.sms is false and a time offset has been previously saved
      if preference.name == 'notification.reminder.sms' && preference.value == false
        pref_to_remove = where(prefable_id: prefable.id).where(prefable_type: prefable.class.name).where(name: 'notification.reminder.sms.notice').first
        pref_to_remove.destroy if pref_to_remove.present?
      end
    else
      preference = self.create(prefable: prefable, name: name, value: value)
    end
    preference
  end
      

end
