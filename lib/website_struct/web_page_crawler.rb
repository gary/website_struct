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
      @page.xpath("(//a[@href]|//link[@href])").
        map { |a| a.attr("href") }.
        to_set -
        stylesheets
    end

    # @return [Set<String] all stylesheets on the page
    def stylesheets
      @page.xpath("//link[@type='text/css']").
        map { |link| link.attr("href") }.
        to_set
    end

    private def valid?(url)
      true if url.scheme =~ /\Ahttps?/
    end
  end
end
