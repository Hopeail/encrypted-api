# name: discourse-encrypted-api
# about: Add encrypted API endpoints with RSA asymmetric encryption
# version: 1.0.0
# authors: Hopeail
# url: https://github.com/Hopeail/encrypted-api

enabled_site_setting :encrypted_api_enabled

# Discourse 插件标准加载方式
# 控制器会在 after_initialize 时自动加载

after_initialize do
  # 延迟加载控制器（避免 db:migrate 时出错）
  module ::EncryptedApi
    class RsaEncryptor
      require 'openssl'
      require 'base64'
      require 'json'

      KEY_LENGTH = 2048

      class << self
        def generate_keypair
          key = OpenSSL::PKey::RSA.new(KEY_LENGTH)
          { public_key: key.public_key.to_pem, private_key: key.to_pem }
        end

        def load_private_key(pem_string)
          OpenSSL::PKey::RSA.new(pem_string)
        end

        def load_public_key(pem_string)
          OpenSSL::PKey::RSA.new(pem_string)
        end

        def sign(data, private_key_pem)
          private_key = load_private_key(private_key_pem)
          signature = private_key.sign(OpenSSL::Digest::SHA256.new, data.to_json)
          Base64.strict_encode64(signature)
        end

        def verify(data, signature_base64, public_key_pem)
          public_key = load_public_key(public_key_pem)
          signature = Base64.strict_decode64(signature_base64)
          public_key.verify(OpenSSL::Digest::SHA256.new, signature, data.to_json)
        end

        def encrypt(data, public_key_pem)
          public_key = load_public_key(public_key_pem)
          encrypted = public_key.public_encrypt(data.to_json)
          Base64.strict_encode64(encrypted)
        end

        def decrypt(encrypted_base64, private_key_pem)
          private_key = load_private_key(private_key_pem)
          encrypted = Base64.strict_decode64(encrypted_base64)
          JSON.parse(private_key.private_decrypt(encrypted))
        end

        def current_private_key
          pem = SiteSetting.encrypted_api_private_key
          raise 'Private key not configured' if pem.blank?
          pem
        end

        def current_public_key
          pem = SiteSetting.encrypted_api_public_key
          raise 'Public key not configured' if pem.blank?
          pem
        end

        def encrypt_response(data)
          timestamp = Time.now.utc.iso8601
          payload = { data: data, timestamp: timestamp }
          signature = sign(payload, current_private_key)
          encrypted_data = encrypt(payload, current_public_key)
          { encrypted: encrypted_data, signature: signature, algorithm: 'RSA-OAEP-SHA256', timestamp: timestamp }
        end
      end
    end
  end

  # 注册 API 路由
  add_api_route :get, '/encrypted/session/current' do
    before { ensure_logged_in }
    action { EncryptedApiController.current_session }
  end

  add_api_route :get, '/encrypted/user/:username/summary' do
    before { ensure_logged_in }
    action { EncryptedApiController.user_summary }
  end

  add_api_route :get, '/encrypted/session/:username' do
    before { ensure_logged_in }
    action { EncryptedApiController.session_username }
  end

  add_api_route :post, '/admin/encrypted/keys/generate' do
    before { ensure_is_admin }
    action { EncryptedApiController.generate_keys }
  end

  add_api_route :get, '/admin/encrypted/keys/public' do
    before { ensure_logged_in }
    action { EncryptedApiController.get_public_key }
  end
end
