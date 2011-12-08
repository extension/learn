xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.id("tag:#{request.host},2005:Error_For/#{request.path}")
  xml.title("eXtension Learn Feed Error")
  xml.link("rel" => "alternate", "href" => root_url)
  xml.link("rel" => "self", "href" => request.url)
  xml.updated(Time.now.utc.xmlschema)
  xml.author do
    xml.name("eXtension Learn")
    xml.email("learn@extension.org")
  end
  xml.entry do
    xml.id("tag:#{request.host},2005:Error For:#{request.path}:#{Time.now.utc.xmlschema}")
    xml.title("eXtension Learn Feed Error")
    xml.link("rel" => "alternate", "href" => request.url)
    xml.updated(Time.now.utc.xmlschema)
    xml.content("type" => "html") do
      xml.text!("<p>#{@errormessage}</p>")
    end
    xml.author do
      xml.name("eXtension Learn")
      xml.email("learn@extension.org")
    end
  end
end
