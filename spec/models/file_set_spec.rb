require 'rails_helper'

describe FileSet do
  it 'is open visibility by default.' do
    expect(subject.visibility).to eq 'open'
  end
end
