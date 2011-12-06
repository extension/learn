# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module MarkupScrubber
  def scrub_and_sanitize(string)
    # make valid html if we don't have it - not sure if this
    # may ever throw an exception, if it does, I probably
    # want to know what caused it, so not catching for now
    valid_html = Nokogiri::HTML::DocumentFragment.parse(string).to_html
   
    # scrub with Loofah prune in order to strip unknown and "unsafe" tags
    # http://loofah.rubyforge.org/loofah/classes/Loofah/Scrubbers/Prune.html#M000036
    scrubbed_html = Loofah.scrub_fragment(valid_html, :prune).to_s
   
    # use ActionController sanitize to sanitize the Loofah scrubbed html
    # see: ActionView::Base.sanitized_allowed_tags for the list of allowed tags
    sanitized_html =  ActionController::Base.helpers.sanitize(scrubbed_html)
    
    # return the sanitized_html
    sanitized_html
  end
end