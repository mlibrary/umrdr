require 'spec_helper'
require 'rails_helper'

describe 'curation_concerns/base/_identifiers_warning.html.erb', type: :view do

  let(:work) do
    stub_model(GenericWork, id: '456', doi: 'doi:10.1000/182')
  end
  let(:ability) { double }

  let(:form) do
    CurationConcerns::GenericWorkForm.new(work, ability)
  end

  let(:current_user) { sub_model(User) }

  before do
    assign(:form, form)
    render partial: "curation_concerns/base/identifiers_warning"
  end

  it "should display a warning about editing and DOI persistence" do
    expect(rendered).to have_content("It is not possible to edit the work and keep the same DOI.")
  end

end
