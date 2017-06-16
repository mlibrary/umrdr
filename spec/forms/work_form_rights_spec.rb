require 'rails_helper'

describe Hyrax::Forms::WorkForm do
  let(:rights) { Hyrax::LicenseService.new.select_all_options[0][-1] }
  let(:work) do
    stub_model(GenericWork, id: '456', rights: [ rights ])
  end
  let(:ability) { nil }
  let(:form) do
    Hyrax::GenericWorkForm.new(work, ability, nil)
  end

  it 'should return attribute as an array' do
    expect(form['rights']).to eq [ rights ]
  end

  it 'should return rights as a single value' do
    expect(form.rights).to eq rights
  end
end
