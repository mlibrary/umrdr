require 'rails_helper'

describe ContactForm do

  describe "it requires input" do

    before do

      subject.contact_method = "Contact Menthod"
      subject.category = "Category"
      subject.name = "John Smith"
      subject.email = "abc@123.com"
      subject.subject = "This is the subject"
      subject.message = "This is a message."

    end


    it "validates contact_method is optional" do

      subject.contact_method = nil
      expect(subject).to be_valid

    end



    it "validates category is required" do

      expect(subject).to be_valid
      subject.category = nil
      expect(subject).not_to be_valid

    end



    it "validates name is required" do

      expect(subject).to be_valid 
      subject.name = nil
      expect(subject).not_to be_valid

    end



    it "validates email is required" do

      expect(subject).to be_valid 
      subject.email = nil
      expect(subject).not_to be_valid

    end



    it "validates subject is required" do

      expect(subject).to be_valid 
      subject.subject = nil
      expect(subject).not_to be_valid

    end

    it "validates message is required" do

      expect(subject).to be_valid 
      subject.message = nil
      expect(subject).not_to be_valid

    end

    it "checks header attributes" do

      subject.subject = "test subject"
      expect(subject.headers).to have_key(:subject)
      expect(subject.headers).to have_value("Deep Blue Data Contact Form:test subject")

      expect(subject.headers).to have_key(:to)
      expect(subject.headers).to have_value(Hyrax.config.contact_email)

      subject.email = "abc@123.com"
      expect(subject.headers).to have_key(:from)
      expect(subject.headers).to have_value("abc@123.com")

    end

  end

end
