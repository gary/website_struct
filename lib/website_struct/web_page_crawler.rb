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
      page_elements = "(//a[#{not_anchors}]|//link[#{http_urls_only}])"

      hrefs(@page.xpath(page_elements)) -
        news_feeds -
        stylesheets
    end

    # @return [Array<String>] all linked pages in the page's domain
    def linked_pages_in_domain
      linked_pages.each_with_object([]) do |url, linked_pages|
        page_url = Addressable::URI.parse(url)

        next if outside_domain?(page_url)

        linked_pages << @url.join(page_url).to_s
      end
    end

    # @return [Set<String> all syndicated news feeds on the page
    def news_feeds
      feed_elements =
        "(//a[#{feed_ext}]|\//link[#{feed_mime_type} or #{xml_ext}])"

      hrefs(@page.xpath(feed_elements))
    end

    # @return [Set<String] all stylesheets on the page
    def stylesheets
      stylesheet_elements =
        "(//link[@type='text/css']|//link[@rel='stylesheet'])"

      hrefs(@page.xpath(stylesheet_elements))
    end

    private def hrefs(elements)
      elements.map { |a| a.attr("href") }.to_set
    end

    private def feed_ext
      "contains(@href, '.atom') or contains(@href, '.rss') or #{xml_ext}"
    end

    private def feed_mime_type
      "@type='application/atom+xml' or @type='application/rss+xml'"
    end

    private def http_urls_only
      "(starts-with(@href, 'http') or starts-with(@href, '/')) and not(@type)"
    end

    private def not_anchors
      "@href and not(starts-with(@href, '#'))"
    end

    private def outside_domain?(url)
      url.absolute? && url.host != @url.host
    end

    private def valid?(url)
      true if url.scheme =~ /\Ahttps?/
    end

    # @note Nokogiri uses libxml, which only supports XPath 1.0
    #   functions. 'contains' is the best choice given that limitation
    #   imo.
    private def xml_ext
      "contains(@href, '.xml')"
    end
  end
end
