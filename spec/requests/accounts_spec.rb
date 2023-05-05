require 'rails_helper'

RSpec.describe 'accounts', type: :request do
  let(:sample_user) do
    { data: {
      name: 'someone',
      password: 'Password1',
      email: 'foo@bar.com'
    } }
  end

  context 'signup' do
    context 'with valid data' do
      it 'should let a valid user register' do
        post '/signup', params: sample_user
        expect(response).to have_http_status :ok
      end

      it 'should return the correct user info' do
        post '/signup', params: sample_user
        expect(response).to have_http_status :ok
        body = JSON.parse(response.body).deep_symbolize_keys
        expect(body).to_not have_key :password
        expect(body[:name]).to eq sample_user[:data][:name]
        expect(body[:email]).to eq sample_user[:data][:email]
      end

      it 'should update the list of users after registration' do
        post '/signup', params: sample_user
        get '/users'
        expect(response).to have_http_status :ok
        body = JSON.parse(response.body)
        user = body.last.deep_symbolize_keys
        expect(user[:name]).to eq sample_user[:data][:name]
        expect(user[:email]).to eq sample_user[:data][:email]
      end
    end

    context 'with invalid data' do
      %i[name password email].each do |key|
        context "missing parameter #{key}" do
          it 'should prevent an invalid user from registering' do
            bad_user = sample_user.clone
            bad_user[:data][key] = ''
            post '/signup', params: bad_user
            expect(response).to have_http_status :bad_request
          end
        end
      end
    end
  end

  context 'login' do
    it 'should prevent an unregistered user from logging in' do
      post '/login', params: sample_user
      expect(response).to have_http_status :unauthorized
    end

    context 'with correct credentials' do
      it 'should log user in upon registration' do
        post '/signup', params: sample_user
        expect(response).to have_http_status :ok
        token = response.headers['Authorization']
        expect(token).to_not be_nil

        headers = { 'Authorization' => token }
        post('/logout', params: sample_user, headers:)
        expect(response).to have_http_status :no_content
      end

      it 'should allow a registered user to login after logging out' do
        post '/signup', params: sample_user
        expect(response).to have_http_status :ok
        token = response.headers['authorization']
        expect(token).to_not be_nil

        headers = { 'authorization' => token }
        post('/logout', params: sample_user, headers:)
        expect(response).to have_http_status :no_content

        post '/login', params: sample_user
        expect(response).to have_http_status :no_content
        expect(response.headers['authorization']).to_not be_nil
      end
    end

    context 'without password' do
      it 'should be prevented from logging in' do
        post '/login', params: sample_user.except(:password)
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'without email' do
      it 'should be prevented from logging in' do
        post '/login', params: sample_user.except(:email)
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  context 'logout' do
    it 'should prevent an unregistered user from logging out' do
      post '/logout', params: sample_user
      expect(response).to have_http_status :not_found
    end

    it 'should log user out' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil

      headers = { 'authorization' => token }
      post('/logout', params: sample_user, headers:)
      expect(response).to have_http_status :no_content
      expect(response.headers['authorization']).to be_nil

      post('/albums', params: {}, headers:)
      expect(response).to have_http_status :unauthorized
    end
  end
end
