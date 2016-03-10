require 'rails_helper'


module TestEngine
  class Engine < ::Rails::Engine
    isolate_namespace TestEngine
  end

  Engine.routes.draw do
    # Contact form routes
    resources :contact_form

  end

  class ContactFormController < ::ContactFormController
  end
end

describe TestEngine::ContactFormController, type: :controller do
  routes { TestEngine::Engine.routes }

  let(:user) { stub_model(User, email: 'bjensen@umich.edu') }

  describe "GET #new" do

    before do
      sign_in user
    end

    describe "#new" do
      let(:raw_params) { HashWithIndifferentAccess.new }
      let(:params) { ActionController::Parameters.new raw_params }

      before { allow(controller).to receive_messages(params: params) }

      it "should have blank subject and category" do
        get :new
        expect(assigns(:contact_form).subject).to be_falsey
        expect(assigns(:contact_form).category).to be_falsey
      end


    end

    describe "#via doi" do

      let(:raw_params) { HashWithIndifferentAccess.new via: 'doi' }
      let(:params) { ActionController::Parameters.new raw_params }
      let(:sample_form) do
        ContactForm.new(
              subject: I18n.t("contact_form.subject.doi_persistence"),
              category: Umrdr::Application.config.contact_issue_type_data_management)
      end

      before { allow(controller).to receive_messages(params: params) }

      it "should set default values via doi" do

        get :new

        new_form = assigns(:contact_form)
        expect(new_form.subject).to eq sample_form.subject
        expect(new_form.category).to eq sample_form.category
      end

    end


  end

end
