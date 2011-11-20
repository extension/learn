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
  PREFERENCES = { 
   'notification.reminder.email' => true,
   'notification.reminder.sms' => false,
   'notification.reminder.sms.notice' => 15.minutes, 
   'notification.activity' => true,
   'notification.recording' => true 
  }
  
  PREFERENCES.each do |name,default|
    constant_name = "#{name.gsub('.','_').upcase}"
    default_constant_name = "#{constant_name}_DEFAULT"
    self.const_set(constant_name,name)
    self.const_set(default_constant_name,default)
  end

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
      default
    end
  end
  
  def self.settingsgroup(group)
    where(group: group)
  end
  
  def self.get_default(name)
    constant_name = "#{self.name}::#{name.gsub('.','_').upcase}_DEFAULT"
    begin
      constant_name.constantize
    rescue
      nil
    end
  end
    

end
