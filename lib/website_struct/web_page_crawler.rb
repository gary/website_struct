require "addressable/uri"

module WebsiteStruct
  # Web page crawler responsible for finding links within the host
  # domain and static assets associated with the url
  class WebPageCrawler
    # @param [String] url the absolute URL of the page to crawl
    # @raise [ArgumentError] if the URL is not absolute or is not a
    #   valid HTTP URL
    def initialize(url)
      @url = Addressable::URI.parse(url)

      abs_http_only = "URL must be absolute and have an HTTP(S) scheme"
      fail ArgumentError, abs_http_only unless valid?(@url)
    end

    private def valid?(url)
      true if url.scheme =~ /\Ahttps?/
    end
  end
end
