# Controller for a page that asks for a company number.
class Organisation::OrganisationNameController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def update
    redirect_to postcode_path(type: 'organisation', id: current_user.organisations.first.id)
  end 

end  
