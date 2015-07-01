require "spec_helper"

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
      specify { expect(subject.linked_pages).to be_a_kind_of Enumerable }

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
          expect(subject.linked_pages).not_to include("/stylesheet.css")
        end
      end

      context "live page", :vcr do
        let(:twitter) do
          "http://twitter.com/intent/user?screen_name=theregister"
        end

        subject { described_class.new("http://www.theregister.co.uk") }

        it "includes relative links" do
          expect(subject.linked_pages).
            to include("/data_centre/").
            and include("/weekend/").
            and include("/about/company/privacy/")
        end

        it "includes absolute links in the host domain" do
          expect(subject.linked_pages).
            to include("http://www.theregister.co.uk/").
            and include("http://m.theregister.co.uk/")
        end

        it "includes links outside the host domain" do
          expect(subject.linked_pages).to include(twitter).
            and include("http://www.facebook.com/VultureCentral")
        end

        it "excludes stylesheets" do
          expect(subject.linked_pages).not_to include("/style_picker/design?b")
        end
      end
    end
  end

  describe "#stylesheets" do
    context "its output" do
      specify { expect(subject.stylesheets).to be_a_kind_of Enumerable }

      context "test link fixture" do
        it "includes relative links to stylesheets" do
          expect(subject.stylesheets).to include("/stylesheet.css")
        end
      end

      context "live page", :vcr do
        subject { described_class.new("http://www.theregister.co.uk") }

        it "includes relative links to stylesheets" do
          expect(subject.stylesheets).to include("/style_picker/design?b")
        end
      end
    end
  end
end
