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
        it "includes relative URLs" do
          expect(subject.linked_pages).to include("/relative-a").
            and include("/relative-a-ext.html").
            and include("/relative-link")
        end

        it "includes absolute URLs in the host domain" do
          expect(subject.linked_pages).to include("https://google.com").
            and include("https://google.com/link")
        end

        it "includes absolute URLs outside the host domain" do
          expect(subject.linked_pages).to include("https://friendster.com").
            and include("https://orkut.com")
        end

        it "excludes anchors" do
          expect(subject.linked_pages).to exclude("#anchor")
        end

        it "excludes URLs with non-HTTP(S) schemes" do
          expect(subject.linked_pages).to exclude("android-app://google.com")
        end

        it "excludes news feeds" do
          expect(subject.linked_pages).to exclude("/rss/feed-a.xml").
            and exclude("http://foo.com/feed-link.rss")
        end

        it "excludes stylesheets" do
          expect(subject.linked_pages).to exclude("/explicit-type.css").
            and exclude("//google.com/rel-no-type.css")
        end
      end

      context "wikipedia", :vcr do
        let(:atom_feed) do
          "https://en.wikipedia.org/w/index.php?title=Special:RecentChanges\
&feed=atom"
        end

        let(:wikimedia) { "//wikimediafoundation.org/" }

        let(:stylesheet) do
          "//en.wikipedia.org/w/load.php?debug=false&lang=en&\
modules=site&only=styles&skin=vector&*"
        end

        let(:url_with_android_scheme) do
          "android-app://org.wikipedia/http/en.m.wikipedia.org/wiki/\
DigitalOcean"
        end

        subject(:digital_ocean) do
          described_class.new("https://en.wikipedia.org/wiki/DigitalOcean")
        end

        it "includes relative URLs" do
          expect(digital_ocean.linked_pages).
            to include("/wiki/Techstars").
            and include("/wiki/Seed_accelerator").
            and include("/wiki/Amazon_Web_Services")
        end

        it "includes absolute URLs in the host domain" do
          expect(digital_ocean.linked_pages).
            to include("//en.wikipedia.org/wiki/Wikipedia:Contact_us").
            and include("https://en.wikipedia.org/wiki/DigitalOcean")
        end

        it "includes absolute URLs outside the host domain" do
          expect(digital_ocean.linked_pages).to include(wikimedia).
            and include("//www.mediawiki.org/")
        end

        it "excludes anchors" do
          expect(digital_ocean.linked_pages).to exclude("#anchor")
        end

        it "excludes URLs with non-HTTP(S) schemes" do
          expect(subject.linked_pages).
            to exclude(url_with_android_scheme)
        end

        it "excludes news feeds" do
          expect(digital_ocean.linked_pages).to exclude(atom_feed)
        end

        it "excludes stylesheets" do
          expect(digital_ocean.linked_pages).to exclude(stylesheet)
        end
      end
    end
  end

  describe "#linked_pages_in_domain" do
    context "test link fixture" do
      context "absolute URL" do
        context "host domain" do
          specify do
            expect(subject.linked_pages_in_domain).
              to include("https://google.com").
              and include("https://google.com/link")
          end
        end

        context "subdomain" do
          specify do
            expect(subject.linked_pages_in_domain).
              to exclude("https://a.google.com").
              and exclude("https://link.google.com")
          end
        end

        context "outside host domain" do
          specify do
            expect(subject.linked_pages_in_domain).
              to exclude("https://orkut.com").
              and exclude("https://friendster.com")
          end
        end
      end

      context "relative URL" do
        it "converts it to an absolute URL" do
          expect(subject.linked_pages_in_domain).
            to include("https://google.com/index.html").
            and include("https://google.com/relative-link").
            and include("https://google.com/relative-a-ext.html").
            and include("https://google.com/relative-a")
        end
      end
    end
  end

  describe "#news_feeds" do
    context "its output" do
      context "test fixture" do
        context "from an a tag" do
          let(:atom_from_a)         { "/atom/feed-a.atom" }
          let(:generic_feed_from_a) { "/rss/feed-a.xml" }
          let(:rss_from_a)          { "/rss/feed-a.rss" }

          it "includes Atom feeds from href attributes" do
            expect(subject.news_feeds).to include(atom_from_a)
          end

          it "includes RSS feeds from href attributes" do
            expect(subject.news_feeds).to include(rss_from_a)
          end

          it "includes URLs from href attributes with XML extensions" do
            expect(subject.news_feeds).to include(generic_feed_from_a)
          end
        end

        context "from a link" do
          let(:atom_from_link)         { "http://foo.com/feed-link.atom" }
          let(:generic_feed_from_link) { "http://foo.com/feed-link.xml" }
          let(:rss_from_link)          { "http://foo.com/feed-link.rss" }

          it "includes Atom feeds from href attributes" do
            expect(subject.news_feeds).to include(atom_from_link)
          end

          it "includes RSS feeds from href attributes" do
            expect(subject.news_feeds).to include(rss_from_link)
          end

          it "includes URLs from href attributes with XML extensions" do
            expect(subject.news_feeds).to include(generic_feed_from_link)
          end
        end
      end

      context "http://www.intertwingly.net/wiki/pie/KnownAtomFeeds" do
        pending("TODO: leverage MIME types")
      end
    end
  end

  describe "#stylesheets" do
    context "its output" do
      context "test link fixture" do
        it "includes relative URLs to stylesheets" do
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

        it "includes absolute URLs to stylesheets" do
          expect(digital_ocean.stylesheets).to include(stylesheet)
        end

        specify { expect(digital_ocean.stylesheets).to have(3).items }
      end
    end
  end
end
