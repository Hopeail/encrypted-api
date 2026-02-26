Discourse::Application.routes.draw do
  # 加密 API 路由
  scope module: 'encrypted_api' do
    get 'encrypted/session/current' => 'encrypted#current_session'
    get 'encrypted/user/:username/summary' => 'encrypted#user_summary'
    get 'encrypted/session/:username' => 'encrypted#session_username'
    
    # 管理员密钥管理
    scope '/admin' do
      post 'encrypted/keys/generate' => 'encrypted_admin#generate_keys'
      get 'encrypted/keys/public' => 'encrypted_admin#get_public_key'
    end
  end
end
