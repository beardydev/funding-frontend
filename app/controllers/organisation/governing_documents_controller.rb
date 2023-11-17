# Controller for the governing documents for an organisation.
class Organisation::GoverningDocumentsController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger


  # This method updates the governing_document_file attribute of an organisation,
  # redirecting to :governing_documents_question if successful and re-rendering
  # :show method if unsuccessful
  def show
    @has_file_upload = true
  end

  def update

    logger.info(
      'Updating governing_document_file for organisation ID: ' \
      "#{@organisation.id}"
    )

    
    @organisation.governing_document_file.attach(organisation_params[:governing_document_file])

    @organisation.save

    @organisation.validate_governing_document_file = true

    if @organisation.valid?

      logger.info(
        'Finished updating governing_document_file for organisation ID: ' \
        "#{@organisation.id}"
      )

      redirect_to organisation_governing_documents_question_path

    else

      logger.info(
        'Validation failed when attempting to update governing_document_file' \
        " for organisation ID: #{@organisation.id}"
      )

      log_errors(@organisation)

      render :show

    end

  end

  def destroy
    @organisation = Organisation.find(params[:organisation_id])

    document = @organisation.governing_document_file.find(params[:id])
  
    document.purge

    redirect_to organisation_governing_documents_question_path(@organisation)
  end

  def question_update
    if params[:organisation].present?
      @organisation.assign_attributes(wants_to_upload_document: params[:organisation][:wants_to_upload_document])
  
      if @organisation.valid?(:governing_documents_question)
        if @organisation.wants_to_upload_document == 'yes'
          redirect_to organisation_governing_documents_path(@organisation)
        else
          redirect_to organisation_summary_path(@organisation)
        end
      else
        render :question
      end
    else
      @organisation.errors.add(:wants_to_upload_document, message: I18n.t('governing_documents_question.errors.text_field_blank'))
      render :question
    end
  end

  def question_show
    @organisation = Organisation.find(params[:organisation_id])
    render :question
  end


  private

  def organisation_params
    params.fetch(:organisation, {}).permit(:governing_document_file)
  end

end
