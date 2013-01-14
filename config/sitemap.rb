# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://#{Settings.urlwriter_host}"

if Settings.sitemap_dir != 'notset'
  SitemapGenerator::Sitemap.sitemaps_path = Settings.sitemap_dir
end

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  
  Event.find_each do |event|
    add(event_path(event), :lastmod => event.updated_at)
  end
  
  Conference.find_each do |conference|
    add(conference_path(conference), :lastmod => conference.updated_at)
  end
  
end
