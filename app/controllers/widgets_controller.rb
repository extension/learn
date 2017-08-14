class WidgetsController < ApplicationController

  def index
    @limit = 3
    # create a unique widget div ID to use as a hook
    @widget_key = "exlw-" + SecureRandom.hex(4)
    @page_meta_description = "Build a custom eXtension events widget"
  end

  def generate_widget_snippet
    if params[:widget_params].nil?
      returninformation = {'message' => 'We are missing the parameters needed to generate the widget code snippet', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
    end
    @widget_key = params[:widget_key]
    @widget_url = widgets_events_url + ".js?" + params[:widget_params]
    respond_to do |format|
      format.js {render :generate_widget_snippet}
    end
  end

  # The front_porch and upcoming methods are used for the first version of the widget.
  # They were replaced with the events method. (Released 3/18/2015)
  # The legacy methods should be removed when the first generation widgets are sunsetted.
  # Update 7/27/2017: front_porch and upcoming have been deprecated
  def deprecated
    render "deprecated_widgets"
  end

  def events

    new_params = []
    if params[:widget_key].present?
      @widget_key = params[:widget_key]
      new_params << "widget_key=#{@widget_key}"
    else
      # this method requires a widget_key param because that's how event.js.erb
      # locates the correct location in the dom to insert the widget.
      returninformation = {'message' => 'We cannot display the example widget because the "widget key" parameter is missing.', 'success' => false}
      return render :json => returninformation.to_json, :status => :unprocessable_entity
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

    if params[:event_type] == "recent"
      @event_type = "recent"
      new_params << "event_type=recent"
    else
      @event_type = "upcoming"
    end

    if request.format == Mime::JS
      # logging of widget use
      # referrer_url and widget fingerprint make a unique pairing
      referrer_url = request.referer
      if referrer_url.present?
        begin
          referrer_host = URI.parse(URI.escape(referrer_url)).host
        rescue URI::InvalidURIError
          referrer_host = nil
        end
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
      @generic_title = "#{@event_type.capitalize} Webinars"

      if params[:operator].present? && params[:operator].downcase == 'and'
        new_params << "operator=and"
        @specific_title = "eXtension #{@event_type.capitalize} Learn Events tagged #{@tag_list.to_sentence}"
        @event_list = Event.active.upcoming_or_recent(@event_type).tagged_with_all(@tag_list).limit(event_limit)
      else
        @specific_title = "eXtension #{@event_type.capitalize} Learn Events tagged #{@tag_list.to_sentence(words_connector: ',', two_words_connector: ' or', last_word_connector: ' or')}"
        @event_list = Event.active.upcoming_or_recent(@event_type).tagged_with(params[:tags]).limit(event_limit)
      end

      if @tag_list.length == 1
        @path_to_upcoming_events = events_tag_url(:tags => @tag_list.first, :type => 'upcoming')
      end

      if @event_list.empty?
        @event_type = "recent"
        @generic_title = "Recent Webinars"
        @specific_title = "eXtension Recent Learn Events tagged #{@tag_list.to_sentence(words_connector: ',', two_words_connector: ' or', last_word_connector: ' or')}"
        @event_list = Event.active.recent.tagged_with(params[:tags]).limit(event_limit)
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
      @event_list = Event.tagged_with(@tag.name).active.upcoming(limit = event_limit)
      if @event_list.empty?
        @generic_title = "Recent Webinars"
        @path_to_upcoming_events = recent_events_url
        @event_type = "recent"
        @specific_title = "eXtension Recent Learn Events tagged Front Page"
        @event_list = Event.active.recent.tagged_with(@tag.name).limit(event_limit)
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
