class Organisation < ApplicationRecord
  include ActiveModel::Validations, GenericValidator, OrganisationHelper

  after_find do |organisation|

    unless organisation.updated_at.today? || organisation.salesforce_account_id.nil? \
      || salesforce_checked_today?(organisation)

      Rails.logger.info "Checking and updating Org with id: #{organisation.id}"
      update_existing_organisation_from_salesforce_details(organisation)

    end 
  end

  self.implicit_order_column = "created_at"

  has_many :pre_applications
  has_many :funding_applications

  has_many :organisations_org_types, inverse_of: :organisation
  has_many :org_types, through: :organisations_org_types

  has_many :users_organisations, inverse_of: :organisation
  has_many :users, through: :users_organisations

  accepts_nested_attributes_for :organisations_org_types, allow_destroy: true

  attr_accessor :has_custom_org_type

  attr_accessor :validate_name
  attr_accessor :validate_org_type
  attr_accessor :validate_custom_org_type
  attr_accessor :validate_address
  attr_accessor :validate_mission
  attr_accessor :validate_board_members_or_trustees
  attr_accessor :validate_vat_registered
  attr_accessor :validate_vat_number
  attr_accessor :validate_company_number
  attr_accessor :validate_charity_number

  validates :org_type, presence: true, if: :validate_org_type?
  validates :custom_org_type, presence: true, if: :validate_custom_org_type?
  validates :name, presence: true, if: :validate_name?
  validates :name, length: { maximum: 255 }
  validates :name, presence: true, if: :validate_address?
  validates :line1, presence: true, if: :validate_address?
  validates :townCity, presence: true, if: :validate_address?
  validates :county, presence: true, if: :validate_address?
  validates :postcode, presence: true, if: :validate_address?
  validates :board_members_or_trustees, numericality: {
    greater_than: -1,
    less_than: 2147483648,
    allow_nil: true
  }, if: :validate_board_members_or_trustees?
  validates_inclusion_of :vat_registered, in: [true, false], if: :validate_vat_registered?
  validates :vat_number, length: { minimum: 9, maximum: 12 }, if: :validate_vat_number?
  validates :company_number, length: { maximum: 20 }, if: :validate_company_number?
  validates :charity_number, length: { maximum: 20 }, if: :validate_charity_number?
  
  def validate_name?
    validate_name == true
  end

  def validate_org_type?
    validate_org_type == true
  end

  def validate_custom_org_type?
    validate_custom_org_type == true
  end

  def validate_address?
    validate_address == true
  end

  def validate_board_members_or_trustees?
    validate_board_members_or_trustees == true
  end
  
  def validate_vat_number?
    validate_vat_number == true
  end

  def validate_company_number?
    validate_company_number == true
  end

  def validate_charity_number?
    validate_charity_number == true
  end

  def validate_vat_registered?
    validate_vat_registered == true
  end

  # Equality function.
  # Compares two organisation based on the attributes that FFE would normally
  # consider mandatory when capturing organisation information before applying
  # for a grant.  Medium grant attributes ignores as they vary per application.
  # @param [other] Organisation The Organisation to compare to self.
  # @return [true/false] Boolean Returns true for a match
  def == (other)
    self.name&.strip&.downcase == other.name&.strip&.downcase &&
    self.org_type&.strip&.downcase == other.org_type&.strip&.downcase &&
    self.line1&.strip&.downcase == other.line1&.strip&.downcase &&
    self.townCity&.strip&.downcase == other.townCity&.strip&.downcase &&
    self.county&.strip&.downcase == other.county&.strip&.downcase &&
    self.postcode&.strip&.downcase == other.postcode&.strip&.downcase &&
    self.company_number&.strip&.downcase == other.company_number&.strip&.downcase &&
    self.charity_number&.strip&.downcase == other.charity_number&.strip&.downcase
  end

  # Org types are set when an applicant initially completes organisation
  # details (The organisation_org_types table has not been used.)
  #
  # The partial, that captures the org types, only shows orgs from 1 to 10
  # 10 is 'other_public_sector_organisation' and the last type a user
  # can select. So any additional org types will require changes in these
  # partials.  And new translations for the application, pre-application,
  # and organisation summary screens.
  #
  # Salesforce merges some org types upon submission like:
  # - Faith based or church organisation (instead of faith or church)
  # - Community of Voluntary group (instead of community or voluntary group)
  # - Registered company or Community Interest Company (instead of reg or com)
  #
  # Future work intends to address this, so changes to an organisation type in
  # Salesforce can be reflected in what FFE stores,
  # when after_find runs above.
  #
  # For cases being imported from GEMS, a new type of unknown as been added.
  # This should be used when FFE can't understand the org type being used.
  #
  enum org_type: {
      registered_charity: 0,
      local_authority: 1,
      registered_company: 2,
      community_interest_company: 3,
      faith_based_organisation: 4,
      church_organisation: 5,
      community_group: 6,
      voluntary_group: 7,
      individual_private_owner_of_heritage: 8,
      other: 9,
      other_public_sector_organisation: 10,
      unknown: 11
  }

end
