# require "rails_helper"

#TODO - write new project spec with organisation upsert info

# RSpec.describe Project, type: :model do
#   describe "Project model" do

#     before do
#         @project = build(
#             :project,
#             id: "2c660111-ab15-4221-98e0-cf0e02748a9b",
#             project_title: "Test Project", start_date: "1/1/2025",
#             end_date: "1/10/2025", line1: "10 Downing Street",
#             line2: "Westminster", townCity: "London", county: "LONDON",
#             postcode: "SW1A 2AA", description: "A description of my project...",
#             difference: "The difference my project will make to...",
#             matter: "My project matters because...",
#             best_placed_description: "My organisation is best placed to...",
#             heritage_description: "The heritage of my project...",
#             involvement_description: "My project will involve a wider range of " \
#                                      "people...",
#             outcome_2: true, outcome_3: false, outcome_4: true, outcome_5: false,
#             outcome_6: true, outcome_7: false, outcome_8: true, outcome_9: false,
#             outcome_2_description: "Description of outcome 2",
#             outcome_3_description: "",
#             outcome_4_description: "Description of outcome 4",
#             outcome_5_description: "",
#             outcome_6_description: "Description of outcome 6",
#             outcome_7_description: "",
#             outcome_8_description: "Description of outcome 8",
#             outcome_9_description: "", permission_type: 2,
#             permission_description: "permission description",
#             partnership_details: "partnership details",
#             declaration_reasons_description: "something"
#         )

#         organisation = build(
#           :organisation,
#           name: "Test Organisation",
#           org_type: 5,
#           charity_number: "12345",
#           company_number: "54321",
#           line1: "10 Downing Street",
#           line2: "Westminster",
#           townCity: "London",
#           county: "LONDON",
#           postcode: "SW1A 2AA",
#           organisation_description: "We do charity based projects",
#       )

#       @project.user.organisations.append(organisation)

#     end

#     context "with a cash contribution" do

#       before do
#         @cash_contribution = build(
#             :cash_contribution,
#             description: "Test Contribution",
#             amount: 1000,
#             secured: 'x_not_sure'
#         )

#         @project.cash_contributions << @cash_contribution

#         @project_salesforce_json = JSON.parse(@project.to_salesforce_json)

#       end

#       it "should serialize Salesforce JSON successfully" do
#          # Assert metadata parameters
#         expect(@project_salesforce_json['meta']['applicationId'])
#             .to eq("2c660111-ab15-4221-98e0-cf0e02748a9b")
#         expect(@project_salesforce_json['meta']['username'])
#             .to eq(@project.user.email)

#         # Assert main contact parameters
#         expect(@project_salesforce_json['application']['mainContactName'])
#             .to eq("Joe Bloggs")
#         expect(@project_salesforce_json['application']['mainContactDateOfBirth'])
#             .to eq("1980-01-01")
#         expect(@project_salesforce_json['application']['mainContactPhone'])
#             .to eq("07123456789")
#         expect(@project_salesforce_json['application']['mainContactEmail'])
#             .to eq(@project.user.email)
#         expect(@project_salesforce_json['application']['mainContactAddress']['line1'])
#             .to eq("10 Downing Street, Westminster")
#         expect(@project_salesforce_json['application']['mainContactAddress']['townCity'])
#             .to eq("London")
#         expect(@project_salesforce_json['application']['mainContactAddress']['county'])
#             .to eq("LONDON")
#         expect(@project_salesforce_json['application']['mainContactAddress']['postcode'])
#             .to eq("SW1A 2AA")

#         # Assert organisation parameters
#         expect(@project_salesforce_json['application']['organisationName'])
#             .to eq("Test Organisation")
#         expect(@project_salesforce_json['application']['organisationType'])
#             .to eq("faith-based-or-church-organisation")
#         expect(@project_salesforce_json['application']['charityNumber'])
#             .to eq("12345")
#         expect(@project_salesforce_json['application']['companyNumber'])
#             .to eq("54321")
#         expect(@project_salesforce_json['application']['organisationAddress']['line1'])
#             .to eq("10 Downing Street, Westminster")
#         expect(@project_salesforce_json['application']['organisationAddress']['townCity'])
#             .to eq("London")
#         expect(@project_salesforce_json['application']['organisationAddress']['county'])
#             .to eq("LONDON")
#         expect(@project_salesforce_json['application']['organisationAddress']['postcode'])
#             .to eq("SW1A 2AA")

#         # Assert project parameters
#         expect(@project_salesforce_json['application']['projectName'])
#             .to eq("Test Project")
#         expect(@project_salesforce_json['application']['projectDateRange']['startDate'])
#             .to eq("2025-01-01")
#         expect(@project_salesforce_json['application']['projectDateRange']['endDate'])
#             .to eq("2025-10-01")
#         expect(@project_salesforce_json['application']['projectAddress']['line1'])
#             .to eq("10 Downing Street, Westminster")
#         expect(@project_salesforce_json['application']['projectAddress']['townCity'])
#             .to eq("London")
#         expect(@project_salesforce_json['application']['projectAddress']['county'])
#             .to eq("LONDON")
#         expect(@project_salesforce_json['application']['projectAddress']['projectPostcode'])
#             .to eq("SW1A 2AA")
#         expect(@project_salesforce_json['application']['yourIdeaProject'])
#             .to eq("A description of my project...")
#         expect(@project_salesforce_json['application']['projectDifference'])
#             .to eq("The difference my project will make to...")
#         expect(@project_salesforce_json['application']['projectOrgBestPlace'])
#             .to eq("My organisation is best placed to...")
#         expect(@project_salesforce_json['application']['projectAvailable'])
#             .to eq("The heritage of my project...")
#         expect(@project_salesforce_json['application']['projectOutcome1'])
#             .to eq("My project will involve a wider range of people...")
#         expect(@project_salesforce_json['application']['projectOutcome2'])
#             .to eq("Description of outcome 2")
#         expect(@project_salesforce_json['application']['projectOutcome3'])
#             .to eq("")
#         expect(@project_salesforce_json['application']['projectOutcome4'])
#             .to eq("Description of outcome 4")
#         expect(@project_salesforce_json['application']['projectOutcome5'])
#             .to eq("")
#         expect(@project_salesforce_json['application']['projectOutcome6'])
#             .to eq("Description of outcome 6")
#         expect(@project_salesforce_json['application']['projectOutcome7'])
#             .to eq("")
#         expect(@project_salesforce_json['application']['projectOutcome8'])
#             .to eq("Description of outcome 8")
#         expect(@project_salesforce_json['application']['projectOutcome9'])
#             .to eq("")
#         expect(@project_salesforce_json['application']['projectOutcome2Checked'])
#             .to eq(true)
#         expect(@project_salesforce_json['application']['projectOutcome3Checked'])
#             .to eq(false)
#         expect(@project_salesforce_json['application']['projectOutcome4Checked'])
#             .to eq(true)
#         expect(@project_salesforce_json['application']['projectOutcome5Checked'])
#             .to eq(false)
#         expect(@project_salesforce_json['application']['projectOutcome6Checked'])
#             .to eq(true)
#         expect(@project_salesforce_json['application']['projectOutcome7Checked'])
#             .to eq(false)
#         expect(@project_salesforce_json['application']['projectOutcome8Checked'])
#             .to eq(true)
#         expect(@project_salesforce_json['application']['projectOutcome9Checked'])
#             .to eq(false)
#         expect(@project_salesforce_json['application']['projectNeedsPermission'])
#             .to eq("not-sure")
#         expect(@project_salesforce_json['application']['projectNeedsPermissionDetails'])
#             .to eq("permission description")
#         expect(@project_salesforce_json['application']['partnershipDetails'])
#             .to eq("partnership details")
#         expect(@project_salesforce_json['application']['informationNotPubliclyAvailableRequest'])
#             .to eq("something")
#         expect(@project_salesforce_json['application']['cashContributions'][0]['description'])
#             .to eq("Test Contribution")
#         expect(@project_salesforce_json['application']['cashContributions'][0]['amount'])
#             .to eq(1000)
#         expect(@project_salesforce_json['application']['cashContributions'][0]['secured'])
#             .to eq('not sure')
#         end
#     end

#     context "without a cash contribution" do
#       before do
#         @project_salesforce_json = JSON.parse(@project.to_salesforce_json)
#       end

#       it "should serialise a project without cash contributions Salesforce JSON successfully" do
#         expect(@project_salesforce_json['application']['cashContributions']).to eq([])
#       end
#     end

#   end
# end