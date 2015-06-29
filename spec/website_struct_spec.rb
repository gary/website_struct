require "spec_helper"

describe WebsiteStruct do
  it "has a version number" do
    expect(WebsiteStruct::VERSION).not_to be_nil
  end
end
