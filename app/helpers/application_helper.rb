# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module ApplicationHelper

  def bootstrap_alert_class(type)
    baseclass = "alert"
    case type
    when :alert
      "#{baseclass} alert-warning"
    when :error
      "#{baseclass} alert-error"
    when :notice
      "#{baseclass} alert-info"
    when :success
      "#{baseclass} alert-success"
    else
      "#{baseclass} #{type.to_s}"
    end
  end

  def avatar_for_learner(learner, options = {})
    image_size = options[:image_size] || :thumb
    case image_size
      when :medium    then image_size_in_px = "100x100"
      when :thumb     then image_size_in_px = "50x50"
    end

    if(options[:event_types])
      is_private = learner.is_private_for_event_types?(options[:event_types])
    else
      is_private = options[:is_private].nil? ? false : options[:is_private]
    end

    if(is_private)
      image_tag("learn_avatar_private.png", :class => 'avatar size' + image_size_in_px, :size => image_size_in_px, :title => 'private profile').html_safe
    elsif(!learner.avatar.present?)
      image_tag("avatar_placeholder.png", :class => 'avatar size' + image_size_in_px, :size => image_size_in_px, :title => learner.name).html_safe
    else
      image_tag(learner.avatar_url(image_size), :class => 'avatar size' + image_size_in_px, :title => learner.name).html_safe
    end
  end

  def link_to_learner(learner, options = {})
    if(learner.nil?)
      return 'unknown'
    end
    if(options[:event_types])
      is_private = learner.is_private_for_event_types?(options[:event_types])
    else
      is_private = options[:is_private].nil? ? false : options[:is_private]
    end

    learner_link = options[:learner_link]
    case learner_link
    when 'portfolio'
      link_path = portfolio_learner_path(learner.id)
    else
      link_path = portfolio_learner_path(learner.id)
    end

    if(!current_learner)
      return (is_private ? 'private profile' : learner.name)
    elsif(!is_private)
      return link_to(learner.name, link_path).html_safe
    elsif(current_learner == learner)
      return link_to("#{learner.name} (seen as private profile)", link_path).html_safe
    else
      # current_learner, current_learner != learner, and is_private
      return 'Private profile'
    end

  end

  def link_to_learner_avatar(learner, options = {})
    if(learner.nil?)
      return ''
    end
    learner_link = options[:learner_link]
    case learner_link
    when 'portfolio'
      link_path = portfolio_learner_path(learner.id)
    else
      link_path = portfolio_learner_path(learner.id)
    end

    if(options[:event_types])
      is_private = learner.is_private_for_event_types?(options[:event_types])
    else
      is_private = options[:is_private].nil? ? false : options[:is_private]
    end

    if(!current_learner)
      return avatar_for_learner(learner,options)
    elsif(!is_private)
      return link_to(avatar_for_learner(learner,options), link_path, :title => learner.name).html_safe
    elsif(current_learner == learner)
      return link_to(avatar_for_learner(learner,options), link_path, {:title => learner.name + " (Your connection is not displayed to other people)", :class => 'private_for_others'}).html_safe
    else
      # current_learner, current_learner != learner, and is_private
      return "<a>#{avatar_for_learner(learner,options)}</a>".html_safe
    end
  end

  def link_to_tag(tag)
    link_to(tag.name, events_tag_path(:tags => tag.name), :class => "tag").html_safe
  end

  def flash_notifications
    message = flash[:error] || flash[:notice] || flash[:warning]
    return_string = ''
    if message
      type = flash.keys[0].to_s
      return_string << '<div id="flash_notification" class="flash_notification ' + type + '"><p>' + message + '</p></div>'
      return return_string.html_safe
    end
  end

  def pagination_counts(collection)
    if(collection.respond_to?('offset_value'))
      "<p>Displaying <strong>#{collection.offset_value + 1}-#{collection.offset_value + collection.size} of #{collection.total_count}</strong></p>".html_safe
    elsif(collection.respond_to?('offset'))
      # hopefully this is an array from search - and while respond_to? doesn't work - probably because
      # offset is a method_missing kind of thing - hopefully it responds to offset - if not, it'll just blow up and we'll deal with it then
      "<p>Displaying <strong>#{collection.offset + 1}-#{collection.offset + collection.size} of #{collection.total_count}</strong></p>".html_safe
    else
      ''
    end
  end

  def sortable_link(column, title = nil, start_date, end_date, tag_tokens)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction, :start_date => start_date, :end_date => end_date, :tag_tokens => tag_tokens}, {:class => css_class}
  end

  def sortable(column, title = nil, start_date, end_date, tag_tokens)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction, :start_date => start_date, :end_date => end_date, :tag_tokens => tag_tokens}, {:class => css_class}
  end

  def timezone_select_default
    reverse_mappings = ActiveSupport::TimeZone::MAPPING.invert
    if cookies[:user_selected_timezone]
      cookies[:user_selected_timezone]
    elsif cookies[:system_timezone]
      reverse_mappings[cookies[:system_timezone]]
    else
      Settings.default_display_timezone
    end
  end

end
