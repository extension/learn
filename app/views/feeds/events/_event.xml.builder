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
  xml.category("scheme" => root_url, "term" => "event_start_date", "label" => event.session_start)
  xml.content("type" => "html") do
    xml.text!(format_text_for_display(event.content_for_atom_entry))
  end
end
