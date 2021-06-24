class DoesNotMatchOtherSignatoryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record == record.organisation.legal_signatories.second && value == record.organisation.legal_signatories.first.email_address
      record.errors.add(attribute, (options[:message] || "must be different to first signatory email address"))
    end
  end
end

class LegalSignatory < ApplicationRecord

  has_many :funding_applications_legal_sigs, inverse_of: :legal_signatory

  belongs_to :organisation
  self.implicit_order_column = "created_at"

  attr_accessor :validate_name
  attr_accessor :validate_email_address
  attr_accessor :validate_phone_number

  validates :name, length: { minimum: 1, maximum: 80 }

  validates :email_address,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            does_not_match_other_signatory: true

  validates :phone_number,
            presence: true

  def validate_name?
    validate_name == true
  end

  def validate_email_address?
    validate_email_address == true
  end

  def validate_phone_number?
    validate_phone_number == true
  end

end
