class UpdateOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :organisation_description, :string
    add_column :organisations, :communities_that_org_serve, :text, array: true
    add_column :organisations, :leadership_self_identify, :text, array: true
    add_column :organisations, :number_of_employees, :integer
    add_column :organisations, :number_of_volunteers, :integer
    add_column :organisations, :volunteer_work_description, :string
    remove_column :organisations, :mission, :string, array: true
    remove_column :organisations, :main_purpose_and_activities, :string
    remove_column :organisations, :social_media_info, :text
    remove_column :organisations, :unrestricted_funds, :decimal 
    remove_column :organisations, :spend_in_last_financial_year, :decimal 
    remove_column :organisations, :charity_number_ni, :integer 
  end
end
