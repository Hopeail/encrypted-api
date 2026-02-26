# name: discourse-encrypted-api
# about: Add encrypted API endpoints with RSA asymmetric encryption
# version: 1.0.0
# authors: Your Name
# url: https://github.com/yourusername/discourse-encrypted-api

enabled_site_setting :encrypted_api_enabled

register_asset 'stylesheets/encrypted-api.scss'

after_initialize do
  # 加载加密工具类
  require_relative 'lib/encrypted_api/rsa_encryptor'

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

  # 管理员密钥管理接口
  add_api_route :post, '/admin/encrypted/keys/generate' do
    before { ensure_is_admin }
    action { EncryptedApiController.generate_keys }
  end

  add_api_route :get, '/admin/encrypted/keys/public' do
    before { ensure_logged_in }
    action { EncryptedApiController.get_public_key }
  end
end
