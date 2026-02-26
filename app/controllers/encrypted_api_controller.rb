# frozen_string_literal: true

module EncryptedApi
  class EncryptedController < ::ApplicationController
    requires_plugin 'discourse-encrypted-api'

    # 接口 1: /encrypted/session/current
    # 参考：/session/current.json
    # 返回当前登录用户的会话信息（加密）
    def current_session
      current_user.ensure_logged_in!

      data = {
        current_user: {
          id: current_user.id,
          username: current_user.username,
          name: current_user.name,
          avatar_template: current_user.avatar_template,
          email: current_user.email,
          admin: current_user.admin?,
          moderator: current_user.moderator?,
          trust_level: current_user.trust_level,
          last_seen_at: current_user.last_seen_at,
          created_at: current_user.created_at
        },
        session: {
          id: session.id,
          csrf_token: session[:csrf_token],
          authenticated: true
        }
      }

      render json: EncryptedApi::RsaEncryptor.encrypt_response(data)
    end

    # 接口 2: /encrypted/user/:username/summary
    # 参考：/u/username/summary.json
    # 返回指定用户的摘要信息（加密）
    def user_summary
      current_user.ensure_logged_in!

      username = params[:username]
      user = User.find_by(username: username)

      if user.blank?
        return render json: { error: 'User not found' }, status: 404
      end

      # 检查权限（只能查看自己的或公开信息）
      unless current_user.admin? || current_user.id == user.id
        # 非管理员只能查看有限的公开信息
        data = {
          user: {
            id: user.id,
            username: user.username,
            name: user.name,
            avatar_template: user.avatar_template,
            trust_level: user.trust_level,
            badge_count: user.badges.count,
            topic_count: user.topics.count,
            post_count: user.posts.count,
            created_at: user.created_at
          },
          access_level: 'limited'
        }
      else
        data = {
          user: {
            id: user.id,
            username: user.username,
            name: user.name,
            avatar_template: user.avatar_template,
            email: user.email,
            admin: user.admin?,
            moderator: user.moderator?,
            trust_level: user.trust_level,
            badge_count: user.badges.count,
            topic_count: user.topics.count,
            post_count: user.posts.count,
            created_at: user.created_at,
            last_seen_at: user.last_seen_at,
            bio_raw: user.user_profile&.bio_raw,
            location: user.user_profile&.location,
            website: user.user_profile&.website
          },
          access_level: 'full'
        }
      end

      render json: EncryptedApi::RsaEncryptor.encrypt_response(data)
    end

    # 接口 3: /encrypted/session/:username
    # 参考：/session/username
    # 验证用户名会话状态（加密）
    def session_username
      current_user.ensure_logged_in!

      username = params[:username]
      user = User.find_by(username: username)

      if user.blank?
        return render json: EncryptedApi::RsaEncryptor.encrypt_response({
          username: username,
          exists: false,
          session_active: false
        })
      end

      # 检查用户是否有活跃会话
      session_active = user.auth_tokens.exists?
      is_current_user = current_user.id == user.id

      data = {
        username: username,
        exists: true,
        user_id: user.id,
        session_active: session_active,
        is_current_user: is_current_user,
        last_seen_at: user.last_seen_at,
        checked_at: Time.now.utc.iso8601
      }

      render json: EncryptedApi::RsaEncryptor.encrypt_response(data)
    end
  end

  # 管理员控制器
  class EncryptedAdminController < ::AdminController
    requires_plugin 'discourse-encrypted-api'

    # 生成新的 RSA 密钥对
    def generate_keys
      keypair = EncryptedApi::RsaEncryptor.generate_keypair

      SiteSetting.encrypted_api_public_key = keypair[:public_key]
      SiteSetting.encrypted_api_private_key = keypair[:private_key]

      render json: {
        success: true,
        message: 'RSA keypair generated successfully',
        public_key_fingerprint: OpenSSL::PKey::RSA.new(keypair[:public_key]).fingerprint
      }
    end

    # 获取公钥（供客户端使用）
    def get_public_key
      public_key = SiteSetting.encrypted_api_public_key

      if public_key.blank?
        return render json: { error: 'Public key not configured' }, status: 404
      end

      key = OpenSSL::PKey::RSA.new(public_key)
      render json: {
        public_key: public_key,
        fingerprint: key.fingerprint,
        key_length: key.n.num_bytes * 8,
        algorithm: 'RSA-OAEP-SHA256'
      }
    end
  end
end
