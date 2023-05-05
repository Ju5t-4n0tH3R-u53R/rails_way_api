require 'rails_helper'

RSpec.describe 'users', type: :request do
  let(:sample_user) { { data: { name: 'Someone', email: 'email@email.com', password: 'Password1' } } }
  let(:invalid_user) { { data: { name: '' } } }

  context 'create' do
    it 'should create a user with 0 total purchases initially' do
      post '/users', params: sample_user
      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id
      expect(body).to include sample_user[:data].except!(:password)

      get "/users/#{body[:id]}"
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include sample_user[:data]
      expect(body).to include :total_purchases
      expect(body[:total_purchases]).to eq 0
    end

    it 'should reject an invalid user' do
      post '/users', params: invalid_user
      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context 'edit' do
    it 'should edit a user' do
      post '/users', params: sample_user
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id

      updated_user = { data: { name: 'some2' } }
      put "/users/#{body[:id]}", params: updated_user
      expect(response).to have_http_status :ok

      get "/users/#{body[:id]}"
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include updated_user[:data]
      expect(body).to include :total_purchases
      expect(body[:total_purchases]).to eq 0
    end

    it 'should reject a user update missing a name' do
      post '/users', params: sample_user
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id

      put "/users/#{body[:id]}", params: invalid_user
      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context 'delete' do
    it 'should delete a user' do
      post '/users', params: sample_user
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id

      delete "/users/#{body[:id]}"
      expect(response).to have_http_status :no_content

      get '/users'
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body)
      expect(body).to be_empty
    end
  end
end
