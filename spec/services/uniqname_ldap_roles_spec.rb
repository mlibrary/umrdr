require 'rails_helper'
require 'net/ldap'

describe Umrdr::UniqnameLdapRoles do

  context "when a uniqname is given" do

    it "returns false for a uniqname known to have no ldap entry" do
      umichinstroles = [" "]
      test = described_class.new('gordonl').faculty_or_staff_roles?(umichinstroles)
      expect(test).to be_falsey
    end

    it "returns false for a uniqname of a non-teaching student known to have an ldap entry" do
      umichinstroles = ["StudentAA", "EnrolledStudentAA"]
      test = described_class.new('gordonl').faculty_or_staff_roles?(umichinstroles)
      expect(test).to be_falsey
    end

    it "returns false for a uniqname of a teaching student known to have an ldap entry" do
      umichinstroles = ["StudentAA", "RegularStaffAA", "EnrolledStudentAA"]
      test = described_class.new('gordonl').faculty_or_staff_roles?(umichinstroles)
      expect(test).to be_falsey
    end


    it "returns false for a uniqname of an alumni" do
      umichinstroles = ["AlumniAA"]
      test = described_class.new('gordonl').faculty_or_staff_roles?(umichinstroles)
      expect(test).to be_falsey
    end

    it "returns true for a uniqname of a regular staff" do
      umichinstroles = ["RegularStaffAA"]
      test = described_class.new('gordonl').faculty_or_staff_roles?(umichinstroles)
      expect(test).to be_truthy
    end

    it "returns true for a uniqname of faculty member" do
      umichinstroles = ["FacultyAA"]
      test = described_class.new('gordonl').faculty_or_staff_roles?(umichinstroles)
      expect(test).to be_truthy
    end

  end
end