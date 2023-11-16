# Controller for a page that asks how many volunteers an organisation has.
class Organisation::NumberOfVolunteersController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger


  # This method updates the number_of_volunteers attribute of an organisation,
  # redirecting to description of volunteers work if yes is selected, 
  # governing docs if no is selected and  and re-rendering
  # :show method if unsuccessful
  def update
    logger.info "Updating number_of_volunteers for organisation ID: #{@organisation.id}"

    @organisation.assign_attributes(organisation_params)

     # Clear number_of_volunteers if has_number_of_volunteers is 'no'
     if params[:organisation][:has_number_of_volunteers] == 'no'
      @organisation.number_of_volunteers = nil
     end

    # Check if has_number_of_volunteers is either 'yes' or 'no'
    unless ['yes', 'no'].include?(params[:organisation][:has_number_of_volunteers])
      @organisation.errors.add(:has_number_of_volunteers, I18n.t('number_of_volunteers.errors.blank'))
      log_errors(@organisation)
      render :show
      return
    end

    # If has_number_of_volunteers is 'yes', ensure number_of_volunteers is provided
    if params[:organisation][:has_number_of_volunteers] == 'yes' && @organisation.number_of_volunteers.blank?
      @organisation.errors.add(:number_of_volunteers, I18n.t('number_of_volunteers.errors.text_field_blank'))
      log_errors(@organisation)
      render :show
      return
    end

    if @organisation.save(context: :number_of_volunteers_update)
      logger.info "Finished updating number_of_volunteers for organisation ID: #{@organisation.id}"
      if params[:organisation][:has_number_of_volunteers] == 'no'
        redirect_to organisation_governing_documents_path
      else
      redirect_to organisation_volunteer_work_description_path
      end
    else
      log_errors(@organisation)
      render :show
    end
  end

  private

  def organisation_params
    # Permit the :has_number_of_volunteers along with :number_of_volunteers
    params.require(:organisation).permit(:number_of_volunteers, :has_number_of_volunteers)
  end
end
