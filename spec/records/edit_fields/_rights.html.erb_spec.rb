require 'spec_helper'
require 'rails_helper'

describe 'records/edit_fields/_rights.html.erb', type: :view do

  include SufiaHelper unless include?(SufiaHelper)

  let(:work) do
    stub_model(GenericWork, id: '456', rights: [ RightsService.select_options[0][-1] ])
  end
  let(:ability) { double }

  let(:curation_concern) {work}

  let(:form) do
    CurationConcerns::GenericWorkForm.new(work, ability)
  end

  let(:current_user) { sub_model(User) }

  let(:f_new) do
    work.rights = nil
    curation_concern = work
    SimpleForm::FormBuilder.new('generic-work', work, view, {})
  end

  let(:f_active_right) do
    work.rights = ["http://rightsstatements.org/vocab/InC/1.0/"]
    curation_concern = work
    SimpleForm::FormBuilder.new('generic-work', work, view, {})
  end

  let(:f_inactive_right) do
    work.rights = ["http://creativecommons.org/licenses/by-sa/3.0/us/"]
    curation_concern = work
    SimpleForm::FormBuilder.new('generic-work', work, view, {})
  end

  it "rights should have asides and descriptions for new work" do

    assign(:form, form)
    allow(view).to receive(:curation_concern).and_return(work) 
    render partial: "records/edit_fields/rights", locals: { f: f_new }

    num_asides = RightsService.select_active_options.length
    expect(rendered).to have_selector(".generic_work_rights .radio aside", count: num_asides)

    RightsService.select_options.each do |right|
      expect(rendered).to have_content(t_uri(:description, scope: [ :rights, right[1] ]))
    end
  end

  it "rights should have asides and descriptions for work with active right" do

    assign(:form, form)
    allow(view).to receive(:curation_concern).and_return(work) 
    render partial: "records/edit_fields/rights", locals: { f: f_active_right }

    num_asides = RightsService.select_active_options.length
    expect(rendered).to have_selector(".generic_work_rights .radio aside", count: num_asides)

    RightsService.select_options.each do |right|
      expect(rendered).to have_content(t_uri(:description, scope: [ :rights, right[1] ]))
    end
  end

  it "rights should have asides and descriptions for work with inactive right" do

    assign(:form, form)
    allow(view).to receive(:curation_concern).and_return(work) 
    render partial: "records/edit_fields/rights", locals: { f: f_inactive_right }

    num_asides = RightsService.select_active_options.length
    expect(rendered).to have_selector(".generic_work_rights .radio aside", count: num_asides)

    RightsService.select_options.each do |right|
      expect(rendered).to have_content(t_uri(:description, scope: [ :rights, right[1] ]))
    end
  end
end