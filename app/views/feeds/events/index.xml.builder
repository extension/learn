xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.id("tag:#{request.host},2005:Learn_Events_Feed/#{request.path}")
  xml.title(@title)
  xml.link("rel" => "alternate", "href" => root_url)
  xml.link("rel" => "self", "href" => request.url)
  xml.updated((@eventlist.first.updated_at + 1).xmlschema)
  xml.author do
    xml.name("eXtension Learn")
    xml.email("learn@extension.org")
  end
  @eventlist.each do |event|
    xml << render(:partial => 'event', :locals => {:event => event})
  end
end
