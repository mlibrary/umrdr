require 'rails_helper'

describe HyraxHelper do
  let(:rights) { Hyrax::LicenseService.new.select_all_options[-1] }
  let(:target) { I18n.t(:description, scope: [ :rights, rights[1].gsub('.', '_') ]) }
  subject { helper.t_uri :description, scope: [ :rights, rights[1] ] }

  it { is_expected.to eq target }

end
