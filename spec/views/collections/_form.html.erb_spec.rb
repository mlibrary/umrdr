require 'spec_helper'

describe 'collections/_form.html.erb' do
  let(:collection) { stub_model(Collection, id: "abc123") }
  let(:collection_form) { Sufia::Forms::CollectionForm.new(collection) }

  before do
    controller.request.path_parameters[:id] = 'j12345'
    assign(:form, collection_form)
  end

  it "draws the metadata fields for collection" do
    render
    expect(rendered).to have_selector("input#collection_title")
    expect(rendered).to_not have_selector("div#additional_title.multi_value")
    expect(rendered).to have_selector("input#collection_creator.multi_value")
    expect(rendered).to have_selector("textarea#collection_description")
    expect(rendered).not_to have_selector("input#collection_date_created")
    expect(rendered).to have_selector("input#collection_language")
    expect(rendered).not_to have_selector("input#collection_visibility")
  end
end
