require 'spec_helper'

describe SufiaHelper do
  let(:rights) { RightsService.select_options[-1] }
  let(:target) { I18n.t(:description, scope: [ :rights, rights[1].gsub('.', '_') ]) }
  subject { helper.t_uri :description, scope: [ :rights, rights[1] ] }

  it { is_expected.to eq target }

end
