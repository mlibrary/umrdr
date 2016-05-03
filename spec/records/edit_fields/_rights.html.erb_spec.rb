require 'spec_helper'
require 'rails_helper'

describe 'records/edit_fields/_rights.html.erb', type: :view do

  include SufiaHelper unless include?(SufiaHelper)

  let(:work) do
    stub_model(GenericWork, id: '456', rights: [ RightsService.select_options[0][-1] ])
  end
  let(:ability) { double }

  let(:form) do
    CurationConcerns::GenericWorkForm.new(work, ability)
  end

  let(:current_user) { sub_model(User) }

  let(:f) do
    SimpleForm::FormBuilder.new('generic-work', work, view, {})
  end

  before do
    assign(:form, form)
    render partial: "records/edit_fields/rights", locals: { f: f }
  end

  it "rights should have descriptions for each right" do
    num_asides = RightsService.select_options.length
    RightsService.select_options.each do |right|
      expect(rendered).to have_content(t_uri(:description, scope: [ :rights, right[1] ]))if !right[1].include?('3.0')
    end
  end

end
