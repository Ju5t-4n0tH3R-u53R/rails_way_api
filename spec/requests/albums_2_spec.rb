require 'rails_helper'

RSpec.describe 'albums', type: :request do
  let(:sample_user) do
    { data: {
      name: 'someone',
      password: 'pass',
      email: 'foo@bar.com'
    } }
  end
  let(:sample_album) do
    { data: {
      title: 'Led Zeppelin IV',
      performer: 'Led Zeppelin',
      cost: 10
    } }
  end

  context 'with authorization' do
    it 'should create the album' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil

      headers = { 'authorization' => token }
      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body)
      album = body.deep_symbolize_keys
      expect(album).to have_key :id
      actual_album = album.slice(:cost, :performer, :title)
      expect(actual_album).to eq sample_album[:data]

      get "/albums/#{album[:id]}"
      expect(response).to have_http_status :ok
    end

    it 'should update the album' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil

      headers = { 'authorization' => token }
      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body)
      album = body.deep_symbolize_keys
      expect(album).to have_key :id

      updated_album = { data: {
        title: 'foo',
        performer: 'bar',
        cost: 42
      } }
      put(
        "/albums/#{album[:id]}",
        params: updated_album,
        headers:
      )
      expect(response).to have_http_status :ok

      get "/albums/#{album[:id]}"
      expect(response).to have_http_status :ok
      body = JSON.parse(response.body)
      album = body.deep_symbolize_keys
      actual_album = album.slice(:cost, :performer, :title)
      expect(actual_album).to eq updated_album[:data]
    end

    it 'should delete the album' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil

      headers = { 'authorization' => token }
      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body)
      album = body.deep_symbolize_keys
      expect(album).to have_key :id

      get "/albums/#{album[:id]}"
      expect(response).to have_http_status :ok

      delete("/albums/#{album[:id]}", headers:)
      expect(response).to have_http_status :no_content

      get "/albums/#{album[:id]}"
      expect(response).to have_http_status :not_found
    end

    context 'with invalid data' do
      it 'missing :data' do
        post '/signup', params: sample_user
        expect(response).to have_http_status :ok
        token = response.headers['authorization']
        expect(token).to_not be_nil

        headers = { 'authorization' => token }
        post('/albums', params: {}, headers:)
        expect(response).to have_http_status :bad_request
      end

      %i[title performer cost].each do |key|
        context "missing parameter #{key}" do
          it 'should prevent an invalid user from registering' do
            post '/signup', params: sample_user
            expect(response).to have_http_status :ok
            token = response.headers['authorization']
            expect(token).to_not be_nil

            headers = { 'authorization' => token }
            bad_album = sample_album.clone
            bad_album[:data][key] = ''
            post('/albums', params: bad_album, headers:)
            expect(response).to have_http_status :unprocessable_entity
          end
        end
      end
    end
  end

  context 'without authorization' do
    it 'should not create an album' do
      headers = { 'authorization' => 'bad token' }
      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :unauthorized
    end

    it 'should not delete an album' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil

      headers = { 'authorization' => token }
      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body)
      album = body.deep_symbolize_keys
      expect(album).to have_key :id

      headers = { 'authorization' => 'bad token' }
      delete("/albums/#{album[:id]}", headers:)
      expect(response).to have_http_status :unauthorized
    end

    it 'should not update an album' do
      post '/signup', params: sample_user
      expect(response).to have_http_status :ok
      token = response.headers['authorization']
      expect(token).to_not be_nil

      headers = { 'authorization' => token }
      post('/albums', params: sample_album, headers:)
      expect(response).to have_http_status :created
      body = JSON.parse(response.body)
      album = body.deep_symbolize_keys
      expect(album).to have_key :id

      headers = { 'authorization' => 'bad token' }
      updated_album = { data: {
        title: 'foo',
        performer: 'bar',
        cost: 42
      } }
      put(
        "/albums/#{album[:id]}",
        params: updated_album,
        headers:
      )
      expect(response).to have_http_status :unauthorized
    end
  end
end
