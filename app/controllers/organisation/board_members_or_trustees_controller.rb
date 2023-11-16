# Controller for a page that asks about the number of board
# members or trustees of an organisation.
class Organisation::BoardMembersOrTrusteesController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def show
    @organisation = current_user.organisations.first
  end

  # This method updates the board_members_or_trustees attribute of an
  # organisation, redirecting to :TODO if successful
  # and re-rendering :show method if unsuccessful
  def update
    logger.info "Updating board_members_or_trustees for organisation ID: #{@organisation.id}"

    @organisation.assign_attributes(organisation_params)

     # Clear board_members_or_trustees if has_board_members_or_trustees is 'no'
     if params[:organisation][:has_board_members_or_trustees] == 'no'
      @organisation.board_members_or_trustees = nil
     end

    # Check if has_board_members_or_trustees is either 'yes' or 'no'
    unless ['yes', 'no'].include?(params[:organisation][:has_board_members_or_trustees])
      @organisation.errors.add(:has_board_members_or_trustees, I18n.t('board_members_or_trustees.errors.blank'))
      log_errors(@organisation)
      render :show
      return
    end

    # If has_board_members_or_trustees is 'yes', ensure board_members_or_trustees is provided
    if params[:organisation][:has_board_members_or_trustees] == 'yes' && @organisation.board_members_or_trustees.blank?
      @organisation.errors.add(:board_members_or_trustees, I18n.t('board_members_or_trustees.errors.text_field_blank'))
      log_errors(@organisation)
      render :show
      return
    end

    if @organisation.save(context: :board_members_or_trustees_update)
      logger.info "Finished updating board_members_or_trustees for organisation ID: #{@organisation.id}"
      redirect_to organisation_number_of_employees_path
    else
      log_errors(@organisation)
      render :show
    end
  end

  private

  def organisation_params

    params.require(:organisation).permit(:board_members_or_trustees, :has_board_members_or_trustees)

  end

end
