class SalesforceExperienceApplication::DeclarationController < ApplicationController
  include SfxPtsPaymentContext
  include PermissionToStartHelper

  def show

  end

  def update

    @salesforce_experience_application.validate_agrees_to_declaration = true
    
    @salesforce_experience_application.agrees_to_declaration = 
      params[:sfx_pts_payment].nil? ? nil : 
        params[:sfx_pts_payment][:agrees_with_declaration_statements] == 'true'
    
    if @salesforce_experience_application.valid?
      
      json_answers = @salesforce_experience_application.pts_answers_json

      json_answers[:agrees_to_declaration] = 
        @salesforce_experience_application.agrees_to_declaration

      @salesforce_experience_application.pts_answers_json = json_answers
      @salesforce_experience_application.save

      redirect_to(
        sfx_pts_payment_upload_permission_to_start_path \
          (@salesforce_experience_application.salesforce_case_id)
      )

    else
       
      render :show

    end

  end
  
end