require "spec_helper"

require "website_struct/web_page_crawler"

describe WebPageCrawler do
  let(:crawler) { described_class }

  describe "#new" do
    context "valid input" do
      context "absolute URL with an HTTP scheme" do
        subject { crawler.new("http://digitalocean.com") }

        it { is_expected.to be_an_instance_of WebPageCrawler }
      end

      context "absolute URL with an HTTPS scheme" do
        subject { crawler.new("https://digitalocean.com") }

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
end
