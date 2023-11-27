require "rails_helper"

RSpec.describe User, type: :model do

  describe "User model" do

    let (:resource) {
      create(
        :user,
        id: 1,
        email: 'a@f.com',
        confirmation_token: 'zsdfasd23e123',
        language_preference: "both"
      )
    } 

    shared_examples "language preference checker" do |language_preference, bilingual, english, welsh|
      before do
        resource.language_preference = language_preference
      end

      it "returns correct boolean for send_bilingual_mails?" do
        expect(resource.send_bilingual_mails?).to eq(bilingual)
      end

      it "returns correct boolean for send_english_mails?" do
        expect(resource.send_english_mails?).to eq(english)
      end

      it "returns correct boolean for send_welsh_mails?" do
        expect(resource.send_welsh_mails?).to eq(welsh)
      end
    end

    context "when language preferences are set to both" do
      it_behaves_like "language preference checker", "both", true, false, false
    end

    context "when language preferences are set to welsh" do
      it_behaves_like "language preference checker", 'welsh', false, false, true
    end

    context "when language preferences are set to english" do
      it_behaves_like "language preference checker", 'english', false, true, false
    end

    context "when language preferences are null" do
      it_behaves_like "language preference checker", nil, false, true, false
    end

    context "when language preferences are mixed case with extra whitespace" do
      it "returns correct boolean results for different language preferences" do
        resource.language_preference = ' eNglISh '
        expect(resource.send_english_mails?).to eq(true)

        resource.language_preference = ' WELsh   '
        expect(resource.send_welsh_mails?).to eq(true)

        resource.language_preference = 'Both   '
        expect(resource.send_bilingual_mails?).to eq(true)
      end
    end

    context "when an unknown language preference is used" do
      it_behaves_like "language preference checker", 'cornish', false, true, false
    end

    context "when email is invalid" do
      let(:invalid_emails) { ['invalid', 'invalid@', 'invalid@.com', '@invalid.com', 'invalid@invalid'] }

      it "should be invalid" do
        invalid_emails.each do |email|
          resource.email = email
          expect(resource.valid?).to eq(false)
        end
      end
    end

    context "when email is valid" do
      let(:valid_emails) { ['valid@example.com', 'valid.name@example.com', 'valid.name+tag@example.co.uk', 'valid-name@example.co.uk'] }
    
      it "should be valid" do
        valid_emails.each do |email|
          resource.email = email
          expect(resource.valid?).to eq(true)
        end
      end
    end

    it 'validates uniqueness of email' do
      # Create a user to have an email in the database that the new user's email will clash with
      existing_user = FactoryBot.create(:user, email: 'test@example.com')
      new_user = User.new(email: 'test@example.com')

      expect(new_user.valid?).to be false
      expect(new_user.errors.messages[:email]).to include('has already been taken')
    end

    describe 'enum roles' do
      it 'defines enum for role with values user and admin' do
        expected_enum = {
          'user' => 0,
          'admin' => 1
        }
        expect(User.defined_enums['role']).to eq(expected_enum)
      end
    end

    describe '#set_default_role' do
      context 'when the record is new' do
        it 'sets the default role to user if role is not set' do
          user = User.new
          expect(user.role).to eq('user')
        end
  
        it 'does not override the role if it is set' do
          user = User.new(role: :admin)
          expect(user.role).to eq('admin')
        end
      end
    end

    describe 'validations' do
      context 'with validate_details set to true' do
        let(:user) { User.new(validate_details: true) }
    
        def expect_user_invalid_and_errors(field, error_messages)
          expect(user.valid?).to be_falsey
          Array(error_messages).each do |error_message|
            expect(user.errors[field]).to include(error_message)
          end
        end
    
        it 'validates name length between 1 and 80' do
          user.name = ''
          expect_user_invalid_and_errors(:name, I18n.t("activerecord.errors.models.user.attributes.name.blank"))
    
          user.name = 'a' * 81
          expect_user_invalid_and_errors(:name, "Your full name must be fewer than 80 characters")
        end
    
        it 'validates presence of dob_day, dob_month, and dob_year' do
          expect_user_invalid_and_errors(:dob_day, I18n.t("activerecord.errors.models.user.attributes.dob_day.blank"))
          expect_user_invalid_and_errors(:dob_month, I18n.t("activerecord.errors.models.user.attributes.dob_month.blank"))
          expect_user_invalid_and_errors(:dob_year, I18n.t("activerecord.errors.models.user.attributes.dob_year.blank"))
        end
    
        it 'validates date of birth is a date and in the past' do
          user.dob_day = 32
          user.dob_month = 12
          user.dob_year = 2000
          expect_user_invalid_and_errors(:date_of_birth, 'Date of birth must be a valid date')
    
          user.dob_day = 10
          user.dob_month = 5
          user.dob_year = 3000
          expect_user_invalid_and_errors(:date_of_birth, 'Date of birth must be in the past')
    
          user.dob_day = 10
          user.dob_month = 5
          user.dob_year = 1900
          expect_user_invalid_and_errors(:date_of_birth, I18n.t("details.dob_error"))
        end
    
      end
    end
    
    context 'with validate_address set to true' do
      let(:user) { User.new(validate_address: true) }
    
      def expect_presence_validation(field)
        expect(user.valid?).to be_falsey
        expect(user.errors[field]).to include(I18n.t("activerecord.errors.models.user.attributes.#{field}.blank"))
      end
    
      it 'validates presence of address fields' do
        expect_presence_validation(:line1)
        expect_presence_validation(:townCity)
        expect_presence_validation(:county)
        expect_presence_validation(:postcode)
      end
    end
  end

  describe 'associations' do
    def check_association(assoc_name, macro, options = {})
      association = described_class.reflect_on_association(assoc_name)
      expect(association.macro).to eq macro
      options.each do |option, value|
        expect(association.options[option]).to eq value
      end
    end
  
    it 'has correct associations' do
      check_association(:users_organisations, :has_many, inverse_of: :user)
      check_association(:organisations, :has_many, through: :users_organisations)
      check_association(:projects, :has_many)
      check_association(:open_medium, :has_many)
      check_association(:person, :belongs_to, optional: true)
    end
  end
  
end
