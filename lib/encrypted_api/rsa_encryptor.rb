# frozen_string_literal: true

module EncryptedApi
  class RsaEncryptor
    require 'openssl'
    require 'base64'
    require 'json'

    # 密钥长度
    KEY_LENGTH = 2048

    class << self
      # 生成 RSA 密钥对
      def generate_keypair
        key = OpenSSL::PKey::RSA.new(KEY_LENGTH)
        {
          public_key: key.public_key.to_pem,
          private_key: key.to_pem
        }
      end

      # 从 PEM 字符串加载私钥
      def load_private_key(pem_string)
        OpenSSL::PKey::RSA.new(pem_string)
      end

      # 从 PEM 字符串加载公钥
      def load_public_key(pem_string)
        OpenSSL::PKey::RSA.new(pem_string)
      end

      # 使用私钥签名数据（用于 API 响应）
      def sign(data, private_key_pem)
        private_key = load_private_key(private_key_pem)
        signature = private_key.sign(OpenSSL::Digest::SHA256.new, data.to_json)
        Base64.strict_encode64(signature)
      end

      # 使用公钥验证签名
      def verify(data, signature_base64, public_key_pem)
        public_key = load_public_key(public_key_pem)
        signature = Base64.strict_decode64(signature_base64)
        public_key.verify(OpenSSL::Digest::SHA256.new, signature, data.to_json)
      end

      # 加密数据（使用公钥）
      def encrypt(data, public_key_pem)
        public_key = load_public_key(public_key_pem)
        encrypted = public_key.public_encrypt(data.to_json)
        Base64.strict_encode64(encrypted)
      end

      # 解密数据（使用私钥）
      def decrypt(encrypted_base64, private_key_pem)
        private_key = load_private_key(private_key_pem)
        encrypted = Base64.strict_decode64(encrypted_base64)
        JSON.parse(private_key.private_decrypt(encrypted))
      end

      # 获取当前配置的私钥（从站点设置）
      def current_private_key
        pem = SiteSetting.encrypted_api_private_key
        raise 'Private key not configured' if pem.blank?
        pem
      end

      # 获取当前配置的公钥（从站点设置）
      def current_public_key
        pem = SiteSetting.encrypted_api_public_key
        raise 'Public key not configured' if pem.blank?
        pem
      end

      # 加密响应数据（标准格式）
      def encrypt_response(data)
        timestamp = Time.now.utc.iso8601
        payload = {
          data: data,
          timestamp: timestamp
        }

        signature = sign(payload, current_private_key)
        encrypted_data = encrypt(payload, current_public_key)

        {
          encrypted: encrypted_data,
          signature: signature,
          algorithm: 'RSA-OAEP-SHA256',
          timestamp: timestamp
        }
      end
    end
  end
end
