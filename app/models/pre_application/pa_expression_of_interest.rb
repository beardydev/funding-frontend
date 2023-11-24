class PaExpressionOfInterest < ApplicationRecord
  include ActiveModel::Validations, GenericValidator
  # This overrides Rails attempting to pluralise the model name
  self.table_name = "pa_expressions_of_interest"
  belongs_to :pre_application

  attr_accessor :validate_heritage_focus
  attr_accessor :validate_what_project_does
  attr_accessor :validate_working_title
  attr_accessor :validate_investment_principles
  attr_accessor :validate_project_reasons
  attr_accessor :validate_project_timescales
  attr_accessor :validate_overall_cost
  attr_accessor :validate_potential_funding_amount
  attr_accessor :validate_likely_submission_description

  validates :working_title, length: { maximum: 255 }, if: :validate_working_title?
  validates :potential_funding_amount, numericality: {
    greater_than: 249999,
    less_than: 2147483648,
    allow_nil: true
  }, if: :validate_potential_funding_amount?

  validate do

    validate_length(
      :what_project_does,
      200,
      I18n.t('activerecord.errors.models.pa_expression_of_interest.attributes.what_project_does.too_long', word_count: 200)
    ) if validate_what_project_does?

    validate_length(
      :investment_principles,
      300,
      I18n.t('activerecord.errors.models.pa_expression_of_interest.attributes.investment_principles.too_long', word_count: 300)
    ) if validate_investment_principles?

    validate_length(
      :heritage_focus,
      100,
      I18n.t('activerecord.errors.models.pa_expression_of_interest.attributes.heritage_focus.too_long', word_count: 100)
    ) if validate_heritage_focus?

    validate_length(
      :project_reasons,
      200,
      I18n.t('activerecord.errors.models.pa_expression_of_interest.attributes.project_reasons.too_long', word_count: 200)
    ) if validate_project_reasons?

    validate_length(
      :project_timescales,
      50,
      I18n.t('activerecord.errors.models.pa_expression_of_interest.attributes.project_timescales.too_long', word_count: 50)
    ) if validate_project_timescales?

    validate_length(
      :overall_cost,
      200,
      I18n.t('activerecord.errors.models.pa_expression_of_interest.attributes.overall_cost.too_long', word_count: 200)
    ) if validate_overall_cost?

    validate_length(
      :likely_submission_description,
      50,
      I18n.t('activerecord.errors.models.pa_expression_of_interest.attributes.likely_submission_description.too_long', word_count: 50)
    ) if validate_likely_submission_description?

  end

  def validate_heritage_focus?
    validate_heritage_focus
  end

  def validate_what_project_does?
    validate_what_project_does
  end

  def validate_working_title?
    validate_working_title
  end

  def validate_investment_principles?
    validate_investment_principles
  end

  def validate_project_reasons?
    validate_project_reasons
  end

  def validate_project_timescales?
    validate_project_timescales
  end

  def validate_overall_cost?
    validate_overall_cost
  end

  def validate_likely_submission_description?
    validate_likely_submission_description
  end

  def validate_potential_funding_amount?
    validate_potential_funding_amount
  end
end