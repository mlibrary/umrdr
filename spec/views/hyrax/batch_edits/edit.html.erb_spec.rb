require 'rails_helper'

describe 'hyrax/batch_edits/edit.html.erb', type: :view do
  let(:generic_work) { stub_model(GenericWork, id: "123", depositor: 'bob', rights: ['']) }
  let(:curation_concern) {generic_work}

  before do
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    controller.prepend_view_path "app/views/hyrax/my"
    assign :names, ['title 1', 'title 2']
    assign :terms, [:description, :rights]
    assign :generic_work, generic_work
    allow(view).to receive(:curation_concern).and_return(generic_work)
    allow(view).to receive(:batch_edits_path).and_return('batch/edits/path')
    view.lookup_context.view_paths.push "#{Hyrax::Engine.root}/app/views/hyrax/base"
    render
  end

  it "draws tooltip for description" do
    expect(rendered).to have_selector ".generic_work_description"
  end
end
