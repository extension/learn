xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.id("tag:#{request.host},2005:Learn Event Feed:#{request.path}")
  xml.title("eXtension Professional Development Sessions")
  xml.link("rel" => "alternate", "href" => event_url(@event))
  xml.link("rel" => "self", "href" => request.url)
  xml.updated((@event.updated_at + 1).xmlschema)
  xml.author do
    xml.name("eXtension Learn")
    xml.email("learn@extension.org")
  end
  xml << render(:partial => 'event', :locals => {:event => @event})
end
