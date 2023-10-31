require 'rails_helper'

# This is a Mock for the RestforceResponse returned
# by RestforceDataClientMock
class MockRestforceResponse

    attr_accessor :response_status

    # status_string - which is 'Success' or 'Fail' is injected
    def initialize(status_string)
        @response_status = status_string
    end

    # @response_status is used for status
    # Other keys are only used for  success scenarios.
    def body
        {
            status: @response_status,
            statusCode: "200",
            projectRefNumber: "NS-19-01498",
            ProjectCostRefID: nil,
            Costs: nil,
            Costheading: nil,
            caseNumber: "00001498",
            caseId: "5002500000BFRUiAAP",
            accountId: "0012500001I6ImfAAF"
        }.to_json
    end

    def status
        @response_status
    end
end

# Mock for the Restsforce data client
# attr_accessor :response_status_success is boolean and
# set from test cases
class RestforceDataClientMock
    attr_accessor :response_status_success
    def post(relative_route, json, content_type)
        if response_status_success
            MockRestforceResponse.new('Success')
        else
            MockRestforceResponse.new('Fail')
        end
    end
end

RSpec.describe ApplicationToSalesforceJob, type: :job do

  # RestforceDataClientMock used to mock Salesforce calls
  let (:rf_data_client_mock) {
    rf_data_client_mock = RestforceDataClientMock.new
  }

  before(:each) do
    stub_request(:post, "https://test.salesforce.com/services/oauth2/token")
        .to_return(
            status: 200,
            body: '{"instance_url":"https://example.salesforce.com/"}'
        )

    user = build(:user)
    user.organisations.append(
        build(:organisation)
    )
    funding_application = create(
        :funding_application,
        organisation: user.organisations.first
    )

    @project = funding_application.project
    
    @project.user = user

    # Mock so Restforce.new returns the mock client
    allow(Restforce).to receive('new').and_return(rf_data_client_mock)

  end

#   it 'throws exception given error response from Salesforce' do

#     # update the mock so that its response is a failed response.
#     rf_data_client_mock.response_status_success = false

#     expect { ApplicationToSalesforceJob.perform_now(@project) }
#         .to raise_error(ApplicationToSalesforceJob::SalesforceApexError)

#   end

#   it "updates the database when run successfully" do

#     # update the mock so that its response is a failed response.
#     rf_data_client_mock.response_status_success = true

#     # User factory doesn't meet the needs of GpProjectMailerHelper.  So stub to return happy path values.
#     allow_any_instance_of(Mailers::GpProjectMailerHelper).to receive(:set_user_instance).and_return(@project.user)
#     allow_any_instance_of(Mailers::GpProjectMailerHelper).to receive(:send_project_english_mails?).and_return(true)
#     allow_any_instance_of(Mailers::GpProjectMailerHelper).to receive(:send_project_welsh_mails?).and_return(false)
#     allow_any_instance_of(Mailers::GpProjectMailerHelper).to receive(:send_project_bilingual_mails?).and_return(false)

#     ApplicationToSalesforceJob.perform_now(@project)

#     expect(@project.funding_application.project_reference_number).to eq("NS-19-01498")
#     expect(@project.funding_application.salesforce_case_id).to eq("5002500000BFRUiAAP")
#     expect(@project.user.organisations.first.salesforce_account_id)
#         .to eq("0012500001I6ImfAAF")
#     expect(@project.funding_application.salesforce_case_number).to eq("00001498")

#   end

end
