# name: discourse-getwmx-api
# about: Add external API endpoint /getwmx to query user data by email + Sidebar Ad List plugin
# version: 2.0.0
# authors: Hopeail
# url: https://github.com/Hopeail/encrypted-api

# GetWMX API 设置
enabled_site_setting :getwmx_api_enabled

# Discourse 2026.2.0 兼容性：避免 db:migrate 阶段加载插件
unless defined?(Rake) && Rake.application.top_tasks.include?('db:migrate')
  after_initialize do
    # ========== GetWMX API 路由 ==========
    add_api_route :get, '/getwmx' do
      before { ensure_api_key }
      action { GetwmxApiController.get_user_by_email }
    end

    add_api_route :get, '/getwmx.json' do
      before { ensure_api_key }
      action { GetwmxApiController.get_user_by_email }
    end

    # ========== 侧边栏广告 API 路由 ==========
    add_api_route :get, '/adlist-sidebar' do
      action { AdlistSidebarController.get_ads }
    end

    add_api_route :get, '/adlist-sidebar.json' do
      action { AdlistSidebarController.get_ads }
    end
  end
end

# ========== 侧边栏广告前端注入 ==========
register_asset 'adlist-sidebar.js'
register_asset 'adlist-sidebar.scss'

# 在话题列表页面注入侧边栏容器
on(:server) do
  Discourse::Application.routes.append do
    get '/sidebar-ads', to: 'adlist_sidebar#show'
  end
end
