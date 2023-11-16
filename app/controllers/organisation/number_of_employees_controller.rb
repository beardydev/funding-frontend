# Controller for a page that asks how many employees an organisation has.
class Organisation::NumberOfEmployeesController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger


  # This method updates the number_of_employees attribute of an organisation,
  # redirecting to :number_of_volunteers if successful and re-rendering
  # :show method if unsuccessful
  def update
    logger.info "Updating number_of_employees for organisation ID: #{@organisation.id}"

    @organisation.assign_attributes(organisation_params)

    # Clear number_of_employees if has_number_of_employees is 'no'
    if params[:organisation][:has_number_of_employees] == 'no'
      @organisation.number_of_employees = nil
    end

    # Check if has_number_of_employees is either 'yes' or 'no'
    unless ['yes', 'no'].include?(params[:organisation][:has_number_of_employees])
      @organisation.errors.add(:has_number_of_employees, I18n.t('number_of_employees.errors.blank'))
      log_errors(@organisation)
      render :show
      return
    end

    # If has_number_of_employees is 'yes', ensure number_of_employees is provided
    if params[:organisation][:has_number_of_employees] == 'yes' && @organisation.number_of_employees.blank?
      @organisation.errors.add(:number_of_employees, I18n.t('number_of_employees.errors.text_field_blank'))
      log_errors(@organisation)
      render :show
      return
    end

    if @organisation.save(context: :number_of_employees_update)
      logger.info "Finished updating number_of_employees for organisation ID: #{@organisation.id}"
      redirect_to organisation_number_of_volunteers_path
    else
      log_errors(@organisation)
      render :show
    end
  end

  private

  def organisation_params
    # Permit the :has_number_of_employees along with :number_of_employees
    params.require(:organisation).permit(:number_of_employees, :has_number_of_employees)
  end
end
