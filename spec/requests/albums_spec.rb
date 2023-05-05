require 'rails_helper'

RSpec.describe 'albums', type: :request do
  let(:sample_user) do
    { data: {
      name: 'someone',
      password: 'pass',
      email: 'foo@bar.com'
    } }
  end
  let(:sample_album) { { data: { title: 'T', performer: 'P', cost: 42 } } }

  context 'create' do
    it 'should create an album' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      get('/albums', headers:)
      expect(response).to have_http_status :ok
      expect(response.content_type).to include('application/json')
      expect(JSON.parse(response.body)).to be_empty

      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id
      expect(body.except!(:last_purchased_at, :last_purchased_by, :created_at, :updated_at)).to include sample_album[:data]

      get("/albums/#{body[:id]}", headers:)
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include sample_album[:data]
    end

    it 'should reject an invalid cost [negative]' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: { data: { title: 'T', performer: 'P', cost: -1 } }, headers:)
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'should reject an invalid cost [zero]' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: { data: { title: 'T', performer: 'P', cost: 0 } }, headers:)
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'should reject an invalid title' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: { data: { title: '', performer: 'P', cost: 1 } }, headers:)
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'should reject an invalid performer' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: { data: { title: 'T', performer: '', cost: 1 } }, headers:)
      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context 'edit' do
    it 'should edit an album' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id

      updated_album = { data: { title: 'U', performer: 'X', cost: 43 } }
      put("/albums/#{body[:id]}", params: updated_album, headers:)
      expect(response).to have_http_status :ok

      get("/albums/#{body[:id]}", headers:)
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include updated_album[:data]
    end

    it 'should reject an invalid update' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id

      updated_album = { data: { title: 'U', performer: 'X', cost: -3 } }
      put("/albums/#{body[:id]}", params: updated_album, headers:)
      expect(response).to have_http_status :unprocessable_entity
    end
  end

  context 'delete' do
    it 'should delete an album' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id

      delete("/albums/#{body[:id]}", headers:)
      expect(response).to have_http_status :no_content

      get('/albums', headers:)
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body)
      expect(body).to be_empty
    end
  end
end
