RSpec.shared_context "WebPageCrawler fixture - links.html" do
  let(:fixture) { File.expand_path("../../../fixtures/links.html", __FILE__) }

  let(:test_links_page) { File.open(fixture, "r") { |f| f.read } }
  let(:test_links) { double(open: test_links_page) }

  subject do
    WebPageCrawler.new("https://google.com", test_links)
  end
end
