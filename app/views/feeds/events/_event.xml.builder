xml.entry do
  xml.id("tag:#{request.host},#{event.created_at.to_date.to_s}:#{event.class.name}/#{event.id}")
  xml.title("type" => "html") do
    xml.text!(event.title)
  end
  xml.link("rel" => "alternate", "href" => event_url(event))
  xml.updated(event.updated_at.xmlschema)
  event.tags.each do |tag|
    xml.category("scheme" => root_url, "term" => tag.name)
  end
  
  xml.content("type" => "xhtml") do
    xml.div("xmlns" => "http://www.w3.org/1999/xhtml", "class" => "vevent") {
      xml.span("class" => "vevent") {  
        xml.span("class" => "summary", "type" => "html") {
          xml.text!(format_text_for_display(event.content_for_atom_entry))
        }
        xml.text!(" on ")
        xml.span("class" => "dtstart") {
          xml.text!(event.session_start.to_time.iso8601)
        }
      }
    }
  end
end
