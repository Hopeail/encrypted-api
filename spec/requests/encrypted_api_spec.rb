# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Encrypted API', type: :request do
  let(:user) { Fabricate(:user) }
  let(:admin) { Fabricate(:admin) }

  before do
    # 生成测试密钥对
    keypair = EncryptedApi::RsaEncryptor.generate_keypair
    SiteSetting.encrypted_api_public_key = keypair[:public_key]
    SiteSetting.encrypted_api_private_key = keypair[:private_key]
  end

  describe 'GET /encrypted/session/current' do
    context 'when logged in' do
      before { sign_in(user) }

      it 'returns encrypted session data' do
        get '/encrypted/session/current.json'
        
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        
        expect(json).to include('encrypted', 'signature', 'algorithm', 'timestamp')
        expect(json['algorithm']).to eq('RSA-OAEP-SHA256')
      end

      it 'includes current user info' do
        get '/encrypted/session/current.json'
        
        json = JSON.parse(response.body)
        decrypted = EncryptedApi::RsaEncryptor.decrypt(json['encrypted'], SiteSetting.encrypted_api_private_key)
        
        expect(decrypted['data']['current_user']['username']).to eq(user.username)
        expect(decrypted['data']['current_user']['id']).to eq(user.id)
      end
    end

    context 'when not logged in' do
      it 'returns 401' do
        get '/encrypted/session/current.json'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /encrypted/user/:username/summary' do
    before { sign_in(user) }

    it 'returns encrypted user summary' do
      get "/encrypted/user/#{user.username}/summary.json"
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      
      expect(json).to include('encrypted', 'signature', 'algorithm')
    end

    it 'returns 404 for non-existent user' do
      get '/encrypted/user/nonexistent/summary.json'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /encrypted/session/:username' do
    before { sign_in(user) }

    it 'returns encrypted session status' do
      get "/encrypted/session/#{user.username}.json"
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      
      expect(json).to include('encrypted', 'signature', 'algorithm')
    end
  end

  describe 'POST /admin/encrypted/keys/generate' do
    context 'when admin' do
      before { sign_in(admin) }

      it 'generates new RSA keypair' do
        post '/admin/encrypted/keys/generate.json'
        
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        
        expect(json['success']).to be true
        expect(json).to include('public_key_fingerprint')
      end
    end

    context 'when not admin' do
      before { sign_in(user) }

      it 'returns 403' do
        post '/admin/encrypted/keys/generate.json'
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /admin/encrypted/keys/public' do
    before { sign_in(user) }

    it 'returns public key' do
      get '/admin/encrypted/keys/public.json'
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      
      expect(json).to include('public_key', 'fingerprint', 'key_length', 'algorithm')
    end
  end
end
