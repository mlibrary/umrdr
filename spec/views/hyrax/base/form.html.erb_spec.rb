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
  let(:work_form) {Hyrax::GenericWorkForm.new(work, ability)}
  let(:proxies) { [stub_model(User, email: 'bob@example.com')] }
  let(:user) { stub_model(User) }
  let(:form) do
    Hyrax::GenericWorkForm.new(work, ability)
  end

  before do
    # mock the helper method
    view.lookup_context.view_paths.push 'app/views/hyrax'
    allow(controller).to receive(:current_user).and_return(user)
    allow(view).to receive(:curation_concern).and_return(work)  
    allow(user).to receive(:can_make_deposits_for).and_return(proxies)
    
    assign(:form, work_form)
    assign(:main_app, main_app) 

  end

  let(:page) do
    view.simple_form_for form do |f|
      render 'hyrax/base/form.html.erb', f: f
    end
    Capybara::Node::Simple.new(rendered)
  end
  
  it "has html5 required attribute for required input fields" do
    input_fields = ["title","creator"]
    input_fields.each do |infield|
      expect(page).to have_selector("input[id='generic_work_#{infield}']") do |selected|
        expect(selected).to have_selector("required")
      end
    end
  end

  it "has html5 required attribute for required text area fields" do
    texta_fields = ["title","creator"]
    texta_fields.each do |tafield|
      expect(page).to have_selector("input[id='generic_work_#{tafield}']") do |selected|
        expect(selected).to have_selector("required")
      end
    end
  end

  it "has html5 required attribute for the rights attribute fields" do
    texta_fields = ["title","creator"]
    texta_fields.each do |tafield|
      expect(page).to have_selector("input[id='generic_work_#{tafield}']") do |selected|
        expect(selected).to have_selector("required")
      end
    end
  end

  # The rights selection by radio button needs to be selected using name instead of id
  # because there are multiple elements that are used for the rights.
  it "has html5 required attribute for all required attribute inputs" do
    expect(page).to have_selector("input[name='generic_work[rights]']") do |selected|
        expect(page).to have_selector("required")
    end
  end
end

