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
  
  xml.content("type" => "html") do
    xml.text!("<div xmlns='http://www.w3.org/1999/xhtml' class='vevent'>") 
      xml.text!("<span class='vevent'>")   
        xml.text!("<span class='summary'>") 
          xml.text!(format_text_for_display(event.content_for_atom_entry))
        xml.text!("</span>")
        xml.text!(" on ")
        xml.text!("<span class='dtstart'>")
          xml.text!(event.session_start.to_time.iso8601)
        xml.text!("</span>")
      xml.text!("</span>")
    xml.text!("</div>")
  end
end
