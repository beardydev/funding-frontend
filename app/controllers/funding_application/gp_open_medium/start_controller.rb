# Controller for the Project 'Start' page
class FundingApplication::GpOpenMedium::StartController < ApplicationController
  before_action :authenticate_user!

  # Method used to create new FundingApplication and OpenMedium objects
  # before redirecting the user to
  # :funding_application_gp_open_medium_main_purpose_of_organisation
  def update

    @application = FundingApplication.create(
      organisation_id: current_user.organisations.first.id
    )

    OpenMedium.create(funding_application_id: @application.id, user: current_user)

    redirect_to(
      funding_application_gp_open_medium_advice_path(
        @application.id
      )
    )

  end

end
