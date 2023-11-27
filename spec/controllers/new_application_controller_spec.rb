require 'rails_helper'

RSpec.describe NewApplicationController do

    describe 'get #show' do
      login_user

      it 'should redirect if the user does not have an organisation' do
        begin
          Flipper[:grant_programme_sff_small].enable

          subject.current_user.organisations.delete_all

          get :show

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(:orchestrate_dashboard_journey)
        ensure
          Flipper[:grant_programme_sff_small].disable
        end
      end

      it 'should redirect if the user\'s organisation details are incomplete' do

        begin
          Flipper[:grant_programme_sff_small].enable

          subject.current_user.organisations.delete_all
          subject.current_user.organisations.new

          get :show

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(:orchestrate_dashboard_journey)
        ensure
          Flipper[:grant_programme_sff_small].disable
        end

      end

      it 'should create a NewApplication object and render the view if the ' \
          'user\'s organisations details are complete' do

        begin
          Flipper[:grant_programme_sff_small].enable

          subject.current_user.organisations.first.update(
            name: 'Test Organisation',
            line1: '10 Downing Street',
            line2: 'Westminster',
            townCity: 'London',
            county: 'London',
            postcode: 'SW1A 2AA',
            org_type: 1
          )

          get :show

          expect(assigns(:application)).to be_an_instance_of NewApplication

          expect(response).to have_http_status(:success)
          expect(response).to render_template(:show)
        ensure
          Flipper[:grant_programme_sff_small].disable
        end
      end

      it 'should redirect to :funding_application_gp_open_medium_start if small grants are closed' do
        begin
          Flipper[:grant_programme_sff_small].disable

          get :show

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(:funding_application_gp_open_medium_start)
        ensure
          Flipper[:grant_programme_sff_small].disable
        end
      end
    end

    describe 'get#update' do
      login_user

      it 'should render the show page if no params are passed' do

        expect(subject).to receive(:log_errors)
        
        put :update, params: { }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
    
        expect(assigns(:application).errors.empty?).to eq(false)
        expect(
            assigns(:application).errors.messages[:application_type][0]
        ).to eq('Select the type of application you wish to start')

      end
  
      it 'should render the show page if an empty new_application param is passed' do

        expect(subject).to receive(:log_errors)

        put :update, params: { new_application: { } }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        
        expect(assigns(:application).errors.empty?).to eq(false)
        expect(
            assigns(:application).errors.messages[:application_type][0]
        ).to eq('Select the type of application you wish to start')

      end

      it 'should render the show page if an empty application_type param is passed' do

        expect(subject).to receive(:log_errors)

        put :update,
            params: { 
              new_application: { 
                application_type: ""
              }
            }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        
        expect(assigns(:application).errors.empty?).to eq(false)
        expect(
            assigns(:application).errors.messages[:application_type][0]
        ).to eq('Select the type of application you wish to start')

      end

      it 'should redirect to authenticated root if the application type is not valid' do

        put :update,
          params: { 
            new_application: {
              application_type: "invalid_type"
            }
          }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(:authenticated_root)

      end

      it 'should redirect to funding_application_gp_project_start if the application_type is sff_small' do 
        begin
          Flipper[:grant_programme_sff_small].enable
          put :update,
            params: {
              new_application: {
                application_type: 'sff_small'
              }
            }

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(:funding_application_gp_project_start)
        ensure
          Flipper[:grant_programme_sff_small].disable
        end
      end
  end
end
