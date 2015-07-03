require "addressable/uri"
require "open-uri"
require "nokogiri"
require "set"

module WebsiteStruct
  # Web page crawler responsible for finding links within the host
  # domain and static assets associated with the url
  class WebPageCrawler
    # @!attribute [r] url
    #   @return the absolute URL of the web page to be crawled
    attr_reader :url

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
      @linked_pages ||= begin
        page_elements = "(//a[#{not_anchors} and #{not_images}]|\
//link[#{http_urls_only} and #{not_images}])"

        hrefs(@page.xpath(page_elements)) - news_feeds - stylesheets
      end
    end

    # @return [Set<String>] all linked pages in the page's domain
    def linked_pages_in_domain
      @linked_pages_in_domain ||= begin
        linked_pages.each_with_object(Set.new) do |url, linked_pages|
          page_url = Addressable::URI.parse(url)

          next if outside_domain?(page_url)

          linked_pages << normalize(@url.join(page_url)).to_s
        end
      end
    end

    # @return [Set<String> all syndicated news feeds on the page
    def news_feeds
      @news_feeds ||= begin
        feed_elements =
          "(//a[#{feed_ext}]|\//link[#{feed_mime_type} or #{xml_ext}])"

        hrefs(@page.xpath(feed_elements))
      end
    end

    # @return [Set<String] all stylesheets on the page
    def stylesheets
      @stylesheets ||= begin
        stylesheet_elements =
          "(//link[@type='text/css']|//link[@rel='stylesheet'])"

        hrefs(@page.xpath(stylesheet_elements))
      end
    end

    private def hrefs(elements)
      elements.map { |a| a.attr("href") }.to_set
    end

    # @return [String] the URL of the web page to be crawled
    def to_s
      @url.to_s
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

    private def normalize(url)
      page_url = Addressable::URI.parse(url)
      if page_url.query || page_url.fragment
        return Addressable::URI.parse(page_url.site + page_url.path)
      end
      page_url
    end

    private def not_anchors
      "@href and not(starts-with(@href, '#'))"
    end

    private def not_images
      "not(contains(@href, '.gif') or contains(@href, '.ico') or \
contains(@href, '.jpg') or contains(@href, '.jpeg') or \
contains(@href, '.png') or contains(@href, '.svg'))"
    end

    private def outside_domain?(url)
      url.host != @url.host if (url.relative? && url.host) || url.absolute?
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
