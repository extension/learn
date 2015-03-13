class WidgetsController < ApplicationController

  def index
    @limit = 3
    # create a unique widget div ID to use as a hook
    @widget_key = "aae-qw-" + SecureRandom.hex(4)
  end

  def generate_widget
    @widget_key = params[:widget_key]
    @widget_url = widgets_events_url + ".js?" + params[:widget_params]
    respond_to do |format|
      format.js {render :generate_widget}
    end
  end

  def front_porch
    @generic_title = "Upcoming Webinars"
    @event_type = "upcoming"
    @specific_title = "eXtension Upcoming Learn Events"
    @path_to_upcoming_events = upcoming_events_url
    @tag = Tag.find_by_name("front page")

    if (!@tag)
      @event_list = []
      return render "widgets"
    end

    if params[:limit].blank? || params[:limit].to_i <= 0
      event_limit = 5
    else
      event_limit = params[:limit].to_i
    end

    @event_list = Event.tagged_with(@tag.name).nonconference.active.upcoming(limit = event_limit)
    if @event_list.empty?
      @generic_title = "Recent Webinars"
      @event_type = "recent"
      @specific_title = "eXtension Recent Learn Events"
      @event_list = Event.nonconference.active.recent.tagged_with(@tag.name).limit(event_limit)
    end

    render "widgets"
  end

  def upcoming
    @event_list = Array.new
    if params[:limit].blank? || params[:limit].to_i <= 0
      event_limit = 5
    else
      event_limit = params[:limit].to_i
    end

    if request.format == Mime::JS
      # logging of widget use
      # referrer_url and widget fingerprint make a unique pairing
      referrer_url = request.referer
      if referrer_url.present?
        referrer_host = URI(referrer_url).host
      else
        referrer_url = nil
        referrer_host = nil
      end

      base_widget_url = "#{request.protocol}#{request.host_with_port}#{request.path}"
      widget_url = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      widget_fingerprint = get_widget_fingerprint(params, base_widget_url)

      existing_widget_log = WidgetLog.where(widget_fingerprint: widget_fingerprint, referrer_url: referrer_url)
      if existing_widget_log.present?
        existing_widget_log.first.update_attribute(:load_count, existing_widget_log.first.load_count + 1)
      else
        WidgetLog.create(referrer_host: referrer_host, referrer_url: referrer_url, base_widget_url: base_widget_url, widget_url: widget_url, widget_fingerprint: widget_fingerprint, load_count: 1)
      end
      ##### End of Widget Logging
    end

    @path_to_upcoming_events = upcoming_events_url

    @showdate_on_past_events = (params[:showdate_on_past_events] == "false" ? false : true)

    if params[:tags].present?
      @tag_list = params[:tags].split(',')
      @event_type = "upcoming"
      @generic_title = "Upcoming Webinars"
      @specific_title = "eXtension Upcoming Learn Events in #{@tag_list.join(',')}"

      if params[:operator].present?
        if params[:operator].downcase == 'and'
          @event_list = Event.nonconference.active.upcoming.tagged_with_all(@tag_list).limit(event_limit)
        end
      elsif params[:operator].blank? || params[:operator].downcase != 'and'
        @event_list = Event.nonconference.active.upcoming.tagged_with(params[:tags]).limit(event_limit)
      end

      if @tag_list.length == 1
        @path_to_upcoming_events = events_tag_url(:tags => @tag_list.first, :type => 'upcoming')
      end

      if @event_list.empty?
        @event_type = "recent"
        @generic_title = "Recent Webinars"
        @specific_title = "eXtension Recent Learn Events in #{@tag_list.join(',')}"
        @event_list = Event.nonconference.active.recent.tagged_with(params[:tags]).limit(event_limit)
        if @tag_list.length == 1
          @path_to_upcoming_events = events_tag_url(:tags => @tag_list.first, :type => 'recent')
        end
      end
    end

    if @event_list.empty?
      @tag = Tag.find_by_name("front page")
      @path_to_upcoming_events = upcoming_events_url
      @generic_title = "Upcoming Webinars"
      @event_type = "upcoming"
      @specific_title = "eXtension Upcoming Learn Events"
      @event_list = Event.tagged_with(@tag.name).nonconference.active.upcoming(limit = event_limit)
      if @event_list.empty?
        @generic_title = "Recent Webinars"
        @path_to_upcoming_events = recent_events_url
        @event_type = "recent"
        @specific_title = "eXtension Recent Learn Events"
        @event_list = Event.nonconference.active.recent.tagged_with(@tag.name).limit(event_limit)
      end
    end

    render "widgets"
  end

  def events

    new_params = []
    if params[:widget_key].present?
      @widget_key = params[:widget_key]
      new_params << "widget_key=#{@widget_key}"
    end

    if params[:width].blank? || params[:width].to_i <= 0
      # @width = 300
    else
      @width = params[:width].to_i
      new_params << "width=#{@width}"
    end

    @event_list = Array.new
    if params[:limit].blank? || params[:limit].to_i <= 0
      event_limit = 5
    else
      event_limit = params[:limit].to_i
      new_params << "limit=#{event_limit}"
    end

    if request.format == Mime::JS
      # logging of widget use
      # referrer_url and widget fingerprint make a unique pairing
      referrer_url = request.referer
      if referrer_url.present?
        referrer_host = URI(referrer_url).host
      else
        referrer_url = nil
        referrer_host = nil
      end

      base_widget_url = "#{request.protocol}#{request.host_with_port}#{request.path}"
      widget_url = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      widget_fingerprint = get_widget_fingerprint(params, base_widget_url)

      existing_widget_log = WidgetLog.where(widget_fingerprint: widget_fingerprint, referrer_url: referrer_url)
      if existing_widget_log.present?
        existing_widget_log.first.update_attribute(:load_count, existing_widget_log.first.load_count + 1)
      else
        WidgetLog.create(referrer_host: referrer_host, referrer_url: referrer_url, base_widget_url: base_widget_url, widget_url: widget_url, widget_fingerprint: widget_fingerprint, load_count: 1)
      end
      ##### End of Widget Logging
    end

    @path_to_upcoming_events = upcoming_events_url

    @showdate_on_past_events = (params[:showdate_on_past_events] == "false" ? false : true)

    if params[:tags].present?
      new_params << "tags=#{params[:tags]}"
      @tag_list = params[:tags].split(',')
      @event_type = "upcoming"
      @generic_title = "Upcoming Webinars"
      @specific_title = "eXtension Upcoming Learn Events tagged #{@tag_list.join(',')}"

      if params[:operator].present?
        if params[:operator].downcase == 'and'
          @event_list = Event.nonconference.active.upcoming.tagged_with_all(@tag_list).limit(event_limit)
        end
      elsif params[:operator].blank? || params[:operator].downcase != 'and'
        @event_list = Event.nonconference.active.upcoming.tagged_with(params[:tags]).limit(event_limit)
      end

      if @tag_list.length == 1
        @path_to_upcoming_events = events_tag_url(:tags => @tag_list.first, :type => 'upcoming')
      end

      if @event_list.empty?
        @event_type = "recent"
        @generic_title = "Recent Webinars"
        @specific_title = "eXtension Recent Learn Events in #{@tag_list.join(',')}"
        @event_list = Event.nonconference.active.recent.tagged_with(params[:tags]).limit(event_limit)
        if @tag_list.length == 1
          @path_to_upcoming_events = events_tag_url(:tags => @tag_list.first, :type => 'recent')
        end
      end
    end

    if @event_list.empty?
      @tag = Tag.find_by_name("front page")
      @path_to_upcoming_events = upcoming_events_url
      @generic_title = "Upcoming Webinars"
      @event_type = "upcoming"
      @specific_title = "eXtension Upcoming Learn Events tagged Front Page"
      @event_list = Event.tagged_with(@tag.name).nonconference.active.upcoming(limit = event_limit)
      if @event_list.empty?
        @generic_title = "Recent Webinars"
        @path_to_upcoming_events = recent_events_url
        @event_type = "recent"
        @specific_title = "eXtension Recent Learn Events"
        @event_list = Event.nonconference.active.recent.tagged_with(@tag.name).limit(event_limit)
      end
    end

    @widget_params = new_params.join("&")

    respond_to do |format|
      format.js {render :events}
    end
  end



  private

  # fingerprint will be generated based on the widget's base url plus it's ordered parameters
  def get_widget_fingerprint(params_hash, base_widget_url)
    params_array = ['base_widget_url', base_widget_url]

    WidgetLog::KNOWN_PARAMS.each do |key|
      if(!params_hash[key].blank?)
        params_array << [key,params_hash[key].split(',').map{|i| i.strip.to_i}.sort]
      end
    end

    return Digest::SHA1.hexdigest(params_array.to_yaml)
  end

end
