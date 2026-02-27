# frozen_string_literal: true

# Discourse Adlist Sidebar Plugin - Controller
# GET /adlist-sidebar - 获取侧边栏广告内容

module ::GetwmxApi
  class AdlistSidebarController < ::ApplicationController
    requires_plugin 'discourse-getwmx-api'

    # 获取侧边栏广告内容
    def get_ads
      ads = build_ads_response

      render json: {
        success: true,
        data: ads,
        fetched_at: Time.now.utc.iso8601
      }
    end

    # Discourse 控制器动作（用于服务器端渲染）
    def show
      ads = build_ads_response
      render json: {
        success: true,
        data: ads
      }
    end

    private

    # 构建广告响应数据
    def build_ads_response
      ads = []

      # 广告位 1 - 顶部横幅
      if SiteSetting.adlist_sidebar_ad1_enabled && SiteSetting.adlist_sidebar_ad1_content.present?
        ads << {
          position: 'top',
          title: SiteSetting.adlist_sidebar_ad1_title,
          content: SiteSetting.adlist_sidebar_ad1_content,
          image_url: SiteSetting.adlist_sidebar_ad1_image_url,
          link_url: SiteSetting.adlist_sidebar_ad1_link_url,
          link_text: SiteSetting.adlist_sidebar_ad1_link_text,
          background_color: SiteSetting.adlist_sidebar_ad1_bg_color,
          text_color: SiteSetting.adlist_sidebar_ad1_text_color
        }
      end

      # 广告位 2 - 中部横幅
      if SiteSetting.adlist_sidebar_ad2_enabled && SiteSetting.adlist_sidebar_ad2_content.present?
        ads << {
          position: 'middle',
          title: SiteSetting.adlist_sidebar_ad2_title,
          content: SiteSetting.adlist_sidebar_ad2_content,
          image_url: SiteSetting.adlist_sidebar_ad2_image_url,
          link_url: SiteSetting.adlist_sidebar_ad2_link_url,
          link_text: SiteSetting.adlist_sidebar_ad2_link_text,
          background_color: SiteSetting.adlist_sidebar_ad2_bg_color,
          text_color: SiteSetting.adlist_sidebar_ad2_text_color
        }
      end

      # 广告位 3 - 底部横幅
      if SiteSetting.adlist_sidebar_ad3_enabled && SiteSetting.adlist_sidebar_ad3_content.present?
        ads << {
          position: 'bottom',
          title: SiteSetting.adlist_sidebar_ad3_title,
          content: SiteSetting.adlist_sidebar_ad3_content,
          image_url: SiteSetting.adlist_sidebar_ad3_image_url,
          link_url: SiteSetting.adlist_sidebar_ad3_link_url,
          link_text: SiteSetting.adlist_sidebar_ad3_link_text,
          background_color: SiteSetting.adlist_sidebar_ad3_bg_color,
          text_color: SiteSetting.adlist_sidebar_ad3_text_color
        }
      end

      # 按配置的位置排序
      position_order = { 'top' => 1, 'middle' => 2, 'bottom' => 3 }
      ads.sort_by { |ad| position_order[ad[:position]] || 99 }
    end
  end
end
