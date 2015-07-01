require "spec_helper"
require "rspec/collection_matchers"

require "support/matchers"
require "support/shared_contexts/web_page_crawler_fixture"
require "support/vcr"

require "website_struct/web_page_crawler"

describe WebPageCrawler do
  include_context "WebPageCrawler fixture - links.html"

  let(:crawler) { described_class }
  let(:fake)    { double(open: "") }

  describe "#new" do
    subject { described_class.new("https://google.com", fake) }

    context "valid input" do
      context "absolute URL with an HTTP scheme" do
        subject { described_class.new("http://google.com", fake) }

        it { is_expected.to be_an_instance_of WebPageCrawler }
      end

      context "absolute URL with an HTTPS scheme" do
        it { is_expected.to be_an_instance_of WebPageCrawler }
      end
    end

    context "invalid input" do
      it "provides a useful error message" do
        expect { crawler.new("foo") }.to raise_error.
          with_message("URL must be absolute and have an HTTP(S) scheme")
      end

      context "absolute URL with non-HTTP scheme" do
        it "raises an ArgumentError" do
          expect { crawler.new("ftp://foo.com") }.to raise_error ArgumentError
        end
      end

      context "relative URL" do
        it "raises an ArgumentError" do
          expect { crawler.new("/foo") }.to raise_error ArgumentError
        end
      end
    end
  end

  describe "#linked_pages" do
    context "its output" do
      context "test link fixture" do
        it "includes relative links" do
          expect(subject.linked_pages).to include("/relative-a").
            and include("/relative-a-ext.html").
            and include("/relative-link")
        end

        it "includes absolute links in the host domain" do
          expect(subject.linked_pages).to include("https://google.com").
            and include("https://google.com/link")
        end

        it "includes links outside the host domain" do
          expect(subject.linked_pages).to include("https://friendster.com").
            and include("https://orkut.com")
        end

        it "excludes stylesheets" do
          expect(subject.linked_pages).to exclude("/explicit-type.css").
            and exclude("//google.com/rel-no-type.css")
        end
      end

      context "wikipedia", :vcr do
        let(:wikimedia) { "//wikimediafoundation.org/" }

        let(:stylesheet) do
          "//en.wikipedia.org/w/load.php?debug=false&lang=en&\
modules=site&only=styles&skin=vector&*"
        end

        subject(:digital_ocean) do
          described_class.new("https://en.wikipedia.org/wiki/DigitalOcean")
        end

        it "includes relative links" do
          expect(digital_ocean.linked_pages).
            to include("/wiki/Techstars").
            and include("/wiki/Seed_accelerator").
            and include("/wiki/Amazon_Web_Services")
        end

        it "includes absolute links in the host domain" do
          expect(digital_ocean.linked_pages).
            to include("//en.wikipedia.org/wiki/Wikipedia:Contact_us").
            and include("https://en.wikipedia.org/wiki/DigitalOcean")
        end

        it "includes links outside the host domain" do
          expect(digital_ocean.linked_pages).to include(wikimedia).
            and include("//www.mediawiki.org/")
        end

        it "excludes stylesheets" do
          expect(digital_ocean.linked_pages).to exclude(stylesheet)
        end
      end
    end
  end

  describe "#stylesheets" do
    context "its output" do
      context "test link fixture" do
        it "includes relative links to stylesheets" do
          expect(subject.stylesheets).to include("/explicit-type.css").
            and include("//google.com/rel-no-type.css")
        end
      end

      context "wikipedia", :vcr do
        let(:stylesheet) do
          "//en.wikipedia.org/w/load.php?debug=false&lang=en&\
modules=site&only=styles&skin=vector&*"
        end
        
        subject(:digital_ocean) do
          described_class.new("https://en.wikipedia.org/wiki/DigitalOcean")
        end

        it "includes absolute links to stylesheets" do
          expect(digital_ocean.stylesheets).to include(stylesheet)
        end

        specify { expect(digital_ocean.stylesheets).to have(3).items }
      end
    end
  end
end
