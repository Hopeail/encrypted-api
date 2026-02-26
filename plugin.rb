# name: discourse-getwmx-api
# about: Add external API endpoint /getwmx to query user data by email
# version: 1.0.0
# authors: Hopeail
# url: https://github.com/Hopeail/encrypted-api

enabled_site_setting :getwmx_api_enabled

# Discourse 2026.2.0 兼容性：避免 db:migrate 阶段加载插件
unless defined?(Rake) && Rake.application.top_tasks.include?('db:migrate')
  after_initialize do
    # 注册 API 路由（对外公开接口）
    add_api_route :get, '/getwmx' do
      before { ensure_api_key }
      action { GetwmxApiController.get_user_by_email }
    end

    # 注册 JSON 版本路由
    add_api_route :get, '/getwmx.json' do
      before { ensure_api_key }
      action { GetwmxApiController.get_user_by_email }
    end
  end
end
