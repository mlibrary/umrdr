require 'rails_helper'

describe 'hyrax/collections/_show_document_list.html.erb', type: :view do
  let(:user) { stub_model(User, user_key: 'njaffer') }
  let(:collection) { mock_model(Collection) }
  let(:config) { Blacklight::Configuration.new }
  let(:identifier) { Time.now().strftime("%s_%N") }
  let(:file) do
    FileSet.create(id: identifier, creator: ["ggm"], title: ['One Hundred Years of Solitude']) do |fs|
      fs.apply_depositor_metadata(user)
    end
  end

  let(:documents) { [file] }
  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  context 'when not logged in' do
    before do
      allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
      allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
      allow(view).to receive(:display_trophy_link).and_return('http://dont.need.no.stinking.badges')
      allow(view).to receive(:current_user).and_return(nil)
      allow(file).to receive(:title_or_label).and_return("One Hundred Years of Solitude")
      allow(file).to receive(:edit_people).and_return([])
    end

    it "renders collection" do
      render(partial: 'hyrax/collections/show_document_list.html.erb', locals: { documents: documents })
      expect(rendered).to have_content 'List of items in this collection'
    end
  end
end
