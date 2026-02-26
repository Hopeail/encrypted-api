# frozen_string_literal: true

# Discourse GetWMX API Plugin - Controller
# GET /getwmx?email=user@example.com

module ::GetwmxApi
  class GetwmxApiController < ::ApplicationController
    requires_plugin 'discourse-getwmx-api'

    # 通过邮箱查询用户数据
    def get_user_by_email
      email = params[:email]&.strip&.downcase

      # 验证邮箱参数
      if email.blank?
        return render json: {
          success: false,
          error: 'Email parameter is required',
          error_code: 'MISSING_EMAIL'
        }, status: 400
      end

      # 验证邮箱格式
      unless email.match?(URI::MailTo::EMAIL_REGEXP)
        return render json: {
          success: false,
          error: 'Invalid email format',
          error_code: 'INVALID_EMAIL'
        }, status: 400
      end

      # 查询用户
      user = User.find_by(email: email)

      if user.blank?
        return render json: {
          success: false,
          error: 'User not found',
          error_code: 'USER_NOT_FOUND'
        }, status: 404
      end

      # 检查权限（只能查询公开用户或管理员可查询所有）
      unless current_user&.admin? || user.public_user?
        return render json: {
          success: false,
          error: 'Access denied - user profile is private',
          error_code: 'ACCESS_DENIED'
        }, status: 403
      end

      # 返回用户数据（脱敏处理）
      user_data = build_user_response(user)

      render json: {
        success: true,
        data: user_data,
        queried_at: Time.now.utc.iso8601
      }
    end

    private

    # 构建用户响应数据（脱敏）
    def build_user_response(user)
      {
        # 基本信息
        id: user.id,
        username: user.username,
        name: user.name,
        avatar_template: user.avatar_template,
        
        # 账户状态
        active: user.active?,
        approved: user.approved?,
        suspended: user.suspended?,
        suspended_till: user.suspended_till,
        
        # 用户等级
        trust_level: user.trust_level,
        moderator: user.moderator?,
        admin: user.admin?,
        staff: user.staff?,
        
        # 统计数据
        topic_count: user.topics.count,
        post_count: user.posts.count,
        badge_count: user.badges.count,
        like_count: user.likes_received.count,
        like_given_count: user.likes_given.count,
        
        # 时间信息
        created_at: user.created_at.iso8601,
        last_seen_at: user.last_seen_at&.iso8601,
        last_posted_at: user.last_posted_at&.iso8601,
        
        # 个人资料（公开部分）
        bio_raw: user.public_bio,
        location: user.location,
        website: user.website,
        twitter_name: user.twitter_name,
        
        # 分组
        groups: user.groups.pluck(:name)
      }
    end

    # 验证 API Key（ Discourse 标准方式）
    def ensure_api_key
      unless current_user&.api_key_valid?
        return render json: {
          success: false,
          error: 'Valid API key required',
          error_code: 'UNAUTHORIZED'
        }, status: 401
      end
    rescue => e
      render json: {
        success: false,
        error: 'Authentication failed',
        error_code: 'AUTH_ERROR',
        details: Rails.env.development? ? e.message : nil
      }, status: 401
    end
  end
end
