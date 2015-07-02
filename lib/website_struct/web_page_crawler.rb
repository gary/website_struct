require "addressable/uri"
require "open-uri"
require "nokogiri"
require "set"

module WebsiteStruct
  # Web page crawler responsible for finding links within the host
  # domain and static assets associated with the url
  class WebPageCrawler
    # @param [String] url the absolute URL of the page to crawl
    # @param [#open] opener interface for opening URLs
    # @raise [ArgumentError] if the URL is not absolute or is not a
    #   valid HTTP URL
    def initialize(url, opener = Kernel)
      @url = Addressable::URI.parse(url)

      abs_http_only = "URL must be absolute and have an HTTP(S) scheme"
      fail ArgumentError, abs_http_only unless valid?(@url)

      @page = Nokogiri::HTML(opener.open(@url))
    end

    # @return [Set<String>] all linked pages on the page
    def linked_pages
      @page.xpath("(//a[#{not_anchors}]|//link[#{http_urls_only}])").
        map { |a| a.attr("href") }.to_set -
        news_feeds -
        stylesheets
    end

    # @return [Set<String> all syndicated news feeds on the page
    def news_feeds
      @page.xpath("(//a[#{feed_extension}]|\
//link[#{feed_mime_type} or #{xml_extension}])").
        map { |a| a.attr("href") }.to_set
    end

    # @return [Set<String] all stylesheets on the page
    def stylesheets
      @page.xpath("(//link[@type='text/css']|//link[@rel='stylesheet'])").
        map { |link| link.attr("href") }.
        to_set
    end

    private def feed_extension
      "contains(@href, '.atom') or contains(@href, '.rss') or #{xml_extension}"
    end

    private def feed_mime_type
      "@type='application/atom+xml' or @type='application/rss+xml'"
    end

    private def http_urls_only
      "starts-with(@href, 'http') or starts-with(@href, '/')"
    end

    private def not_anchors
      "not(starts-with(@href, '#'))"
    end

    private def valid?(url)
      true if url.scheme =~ /\Ahttps?/
    end

    # @note Nokogiri uses libxml, which only supports XPath 1.0
    #   functions. 'contains' is the best choice given that limitation
    #   imo.
    private def xml_extension
      "contains(@href, '.xml')"
    end
  end
end
