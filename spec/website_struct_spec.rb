require "spec_helper"

describe WebsiteStruct do
  it "has a version number" do
    expect(WebsiteStruct::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
