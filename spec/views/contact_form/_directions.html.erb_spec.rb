require 'rails_helper.rb'

describe "contact_form/_directions.html.erb"  do

  it "displays directions text" do
    render
    expect(rendered).to match(/We are happy to answer any questions you have about managing and sharing your data and hear your feedback on how we can improve our services. Please fill out the contact form below or email <a href="mailto:deepblue@umich.edu">deepblue@umich.edu<\/a>/)
  end
end
