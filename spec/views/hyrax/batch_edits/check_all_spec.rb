require 'rails_helper'

describe 'hyrax/batch_edits/check_all.html.erb', type: :view do
  before do
    allow(controller).to receive(:controller_name).and_return('my')
    controller.prepend_view_path "app/views/hyrax/my"
    render 'hyrax/batch_edits/check_all'
  end

  it 'renders actions for my items' do
    expect(rendered).to_not have_selector("li[data-behavior='batch-edit-select-none']")
    expect(rendered).to_not have_selector("li[data-behavior='batch-edit-select-page']")
  end
end
