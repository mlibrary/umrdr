require 'rails_helper'

def required_attributes
  GenericWork.validators
    .select{|v| v.is_a? ActiveModel::Validations::PresenceValidator}
    .map{|v| v.attributes}
    .flatten
    .map(&:to_s)
end

describe "Work Edit Form" do
  let(:work) {stub_model(GenericWork, id: '123')}
  let(:ability) { nil }
  let(:curation_concern) {work}
  let(:work_form) {CurationConcerns::GenericWorkForm.new(work, ability)}

  before do
    # mock the helper method
    allow(view).to receive(:curation_concern).and_return(work)
    assign(:form, work_form)
    assign(:main_app, main_app)

    render partial: "curation_concerns/base/form.html.erb"
  end

  it "has html5 required attribute for required input fields" do
    input_fields = ["title","creator"]
    input_fields.each do |infield|
      expect(rendered).to have_selector("input[id='generic_work_#{infield}']") do |selected|
        expect(selected).to have_selector("required")
      end
    end
  end

  it "has html5 required attribute for required text area fields" do
    texta_fields = ["title","creator"]
    texta_fields.each do |tafield|
      expect(rendered).to have_selector("input[id='generic_work_#{tafield}']") do |selected|
        expect(selected).to have_selector("required")
      end
    end
  end

  it "has html5 required attribute for the rights attribute fields" do
    texta_fields = ["title","creator"]
    texta_fields.each do |tafield|
      expect(rendered).to have_selector("input[id='generic_work_#{tafield}']") do |selected|
        expect(selected).to have_selector("required")
      end
    end
  end

  # The rights selection by radio button needs to be selected using name instead of id
  # because there are multiple elements that are used for the rights.
  it "has html5 required attribute for all required attribute inputs" do
    expect(rendered).to have_selector("input[name='generic_work[rights]']") do |selected|
        expect(selected).to have_selector("required")
    end
  end
end

