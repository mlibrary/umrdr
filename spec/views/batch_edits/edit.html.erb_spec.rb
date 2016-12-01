require 'spec_helper'

RSpec.describe 'batch_edits/edit.html.erb' do
  let(:generic_work) { stub_model(GenericWork, id: nil, depositor: 'bob', rights: ['']) }
  let(:curation_concern) {generic_work}

  before do
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    assign :names, ['title 1', 'title 2']
    assign :terms, [:description, :rights]
    assign :generic_work, generic_work
    allow(view).to receive(:curation_concern).and_return(generic_work)

    view.lookup_context.view_paths.push "#{CurationConcerns::Engine.root}/app/views/curation_concerns/base"
    render
  end

  it "draws tooltip for description" do
    expect(rendered).to have_selector ".generic_work_description"
  end
end
