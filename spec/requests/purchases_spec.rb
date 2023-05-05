require 'rails_helper'

RSpec.describe 'purchases', type: :request do
  let(:sample_album) { { data: { title: 'T', performer: 'P', cost: 42 } } }
  let(:sample_user) do
    { data: {
      name: 'someone',
      password: 'pass',
      email: 'foo@bar.com'
    } }
  end
  let(:sample_purchase) { { data: { user_id: 1, album_id: 1 } } }

  context 'create' do
    it 'should create a purchase' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created

      post('/users', params: sample_user, headers:)
      expect(response).to have_http_status :created

      get('/purchases', headers:)
      expect(response).to have_http_status :ok
      expect(response.content_type).to include('application/json')
      expect(JSON.parse(response.body)).to be_empty

      post('/purchases', params: sample_purchase, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id
      expect(body).to include sample_purchase[:data]

      get("/purchases/#{body[:id]}", headers:)
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include sample_purchase[:data]
    end

    it "should update user's total_purchases after making a purchase" do
      post('/signup', params: sample_user, headers:)
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }
      user_id = JSON.parse(response.body).deep_symbolize_keys[:id]

      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created

      post('/purchases', params: sample_purchase, headers:)
      expect(response).to have_http_status :created

      get("/users/#{user_id}", headers:)
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include sample_user[:data].except!(:password)
      expect(body).to include :total_purchases
      expect(body[:total_purchases]).to eq 1
    end

    it "should update album's last_purchased fields after making a purchase" do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }
      user_id = JSON.parse(response.body).deep_symbolize_keys[:id]

      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id
      album_id = body[:id]

      post('/purchases', params: sample_purchase, headers:)
      expect(response).to have_http_status :created

      get("/albums/#{album_id}", headers:)
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include sample_album[:data]
      expect(body).to include :last_purchased_at
      expect(body).to include :last_purchased_by
      expect { Time.parse body[:last_purchased_at] }.not_to raise_error
      expect(body[:last_purchased_by]).to eq user_id
    end
  end

  context 'edit' do
    it 'should edit a purchase' do
      second_album = { data: { title: 'U', performer: 'W', cost: 40 } }
      second_user = {
        data: {
          name: 'someone',
          password: 'pass',
          email: 'foo@bar.com'
        }
      }
      updated_purchase = { data: { user_id: 2, album_id: 2 } }

      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      post('/users', params: sample_user, headers:)
      expect(response).to have_http_status :created
      post('/albums', params: second_album, headers:)
      expect(response).to have_http_status :created
      post('/users', params: second_user, headers:)
      expect(response).to have_http_status :created

      post('/purchases', params: sample_purchase, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id

      put("/purchases/#{body[:id]}", params: updated_purchase, headers:)
      expect(response).to have_http_status :ok

      get("/purchases/#{body[:id]}", headers:)
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include updated_purchase[:data]
    end
  end

  context 'delete' do
    it 'should delete a purchase' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil
      headers = { 'authorization' => token }

      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created

      post('/users', params: sample_user, headers:)
      expect(response).to have_http_status :created

      post('/purchases', params: sample_purchase, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(body).to include :id

      delete("/purchases/#{body[:id]}", headers:)
      expect(response).to have_http_status :no_content

      get('/purchases', headers:)
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body)
      expect(body).to be_empty
    end
  end
end
