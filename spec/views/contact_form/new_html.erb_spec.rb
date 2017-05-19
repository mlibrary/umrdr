require 'rails_helper'


describe "contact_form/new.html.erb"  do

  let!(:user) { stub_model(User, user_key: 'mjg') }

  before do
    allow(view).to receive(:current_user).and_return(user)
    assign(:user, user) 
  end
  
  it "displays fields appropriate fields when user is not signed in" do

    @contact_formone = Sufia::Forms::ContactForm.new()
    assign(:contact_form, @contact_formone )
    allow(view).to receive(:user_signed_in?) { false }

    render

    expect(rendered).to have_field('Your Name')
    expect(rendered).to have_field('Your Email')
    expect(rendered).to have_field('What do you need help with?')
    expect(rendered).to have_field("Subject")
    expect(rendered).to have_field('Your Message')

    expect(rendered).to_not have_selector("label[class='control-label']", :text=>"Your Email")
    expect(rendered).to_not have_selector("p", :text=>"mjg")


  end
end



