# Controller for the governing documents for an organisation.
class Organisation::GoverningDocumentsController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def update
    redirect_to organisation_governing_documents_question_path
  end

  def question_update
    redirect_to organisation_summary_path
  end

  def question_show
    render :question
  end
  # This method updates the governing_document_file attribute of an organisation,
  # redirecting to :summary if successful and re-rendering
  # :show method if unsuccessful
  # def show
  #   @has_file_upload = true
  # end

  # def update

  #   logger.info "Updating governing_document_file for organisation ID: #{@organisation.id}"

  #   @organisation.validate_governing_document_file = true

  #   @organisation.update(organisation_params)

  #   if @organisation.valid?

  #     logger.info "Finished updating governing_document_file for organisation ID: #{@organisation.id}"

  #     redirect_to :summary

  #   else

  #     logger.info "Validation failed when attempting to update governing_document_file for organisation ID: #{@organisation.id}"

  #     log_errors(@organisation)

  #     render :show

  #   end
  # end

  private

  def organisation_params

    params.require(:organisation).permit(:governing_document_file)

  end

end
