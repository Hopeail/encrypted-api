/**
 * Discourse Adlist Sidebar Plugin
 * Displays configurable advertisements in the topic list sidebar
 * 
 * Features:
 * - Up to 3 ad slots (top, middle, bottom)
 * - Configurable via admin settings
 * - Responsive (hidden on mobile < 768px)
 * - Fetches ad content from /adlist-sidebar API endpoint
 */

import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";
import { url } from "discourse/lib/computed";

function initializeAdlistSidebar(api) {
  const siteSettings = api.container.lookup("site-settings:main");
  
  // 如果插件未启用，直接返回
  if (!siteSettings.adlist_sidebar_enabled) {
    return;
  }

  // 侧边栏位置
  const sidebarPosition = siteSettings.adlist_sidebar_position || 'right';
  
  // 最小显示宽度
  const minWidth = siteSettings.adlist_sidebar_min_width || 768;

  // 检查当前页面是否应该显示侧边栏
  function shouldShowSidebar() {
    const currentPath = window.location.pathname;
    
    // 检查页面类型
    const showOnLatest = siteSettings.adlist_sidebar_show_on_latest;
    const showOnNew = siteSettings.adlist_sidebar_show_on_new;
    const showOnUnread = siteSettings.adlist_sidebar_show_on_unread;
    const showOnTop = siteSettings.adlist_sidebar_show_on_top;
    const showOnCategory = siteSettings.adlist_sidebar_show_on_category;
    
    if (showOnLatest && (currentPath === '/' || currentPath === '/latest')) {
      return true;
    }
    if (showOnNew && currentPath === '/new') {
      return true;
    }
    if (showOnUnread && currentPath === '/unread') {
      return true;
    }
    if (showOnTop && currentPath === '/top') {
      return true;
    }
    if (showOnCategory && currentPath.match(/^\/c\/[^/]+/)) {
      return true;
    }
    
    return false;
  }

  // 检查屏幕宽度
  function isScreenWideEnough() {
    return window.innerWidth >= minWidth;
  }

  // 渲染广告内容
  function renderAds(ads) {
    // 移除旧的侧边栏（如果存在）
    const existingSidebar = document.querySelector('.adlist-sidebar-container');
    if (existingSidebar) {
      existingSidebar.remove();
    }

    if (!ads || ads.length === 0) {
      return;
    }

    // 创建侧边栏容器
    const sidebarContainer = document.createElement('div');
    sidebarContainer.className = `adlist-sidebar-container adlist-sidebar-${sidebarPosition}`;
    sidebarContainer.setAttribute('aria-label', 'Sidebar advertisements');

    // 渲染每个广告
    ads.forEach((ad, index) => {
      const adElement = createAdElement(ad, index);
      if (adElement) {
        sidebarContainer.appendChild(adElement);
      }
    });

    // 插入到页面中
    insertSidebarIntoPage(sidebarContainer, sidebarPosition);
  }

  // 创建单个广告元素
  function createAdElement(ad, index) {
    const adDiv = document.createElement('div');
    adDiv.className = `adlist-ad adlist-ad-${ad.position} adlist-ad-${index + 1}`;
    
    // 应用自定义样式
    if (ad.background_color) {
      adDiv.style.backgroundColor = ad.background_color;
    }
    if (ad.text_color) {
      adDiv.style.color = ad.text_color;
    }

    // 广告内容 HTML
    let contentHtml = '';
    
    if (ad.title) {
      contentHtml += `<h3 class="adlist-ad-title">${escapeHtml(ad.title)}</h3>`;
    }
    
    if (ad.image_url) {
      contentHtml += `<img src="${escapeHtml(ad.image_url)}" alt="${escapeHtml(ad.title || 'Advertisement')}" class="adlist-ad-image" />`;
    }
    
    if (ad.content) {
      contentHtml += `<div class="adlist-ad-content">${ad.content}</div>`;
    }
    
    if (ad.link_url && ad.link_text) {
      contentHtml += `<a href="${escapeHtml(ad.link_url)}" class="adlist-ad-link" target="_blank" rel="noopener noreferrer">${escapeHtml(ad.link_text)}</a>`;
    } else if (ad.link_url) {
      // 如果只有链接没有文字，将整个广告作为可点击区域
      adDiv.style.cursor = 'pointer';
      adDiv.onclick = () => window.open(ad.link_url, '_blank', 'noopener,noreferrer');
    }

    adDiv.innerHTML = contentHtml;
    return adDiv;
  }

  // 将侧边栏插入页面
  function insertSidebarIntoPage(sidebarContainer, position) {
    // 查找话题列表容器
    const topicListContainer = document.querySelector('.topic-list-container') || 
                               document.querySelector('.contents') ||
                               document.querySelector('#main-outlet');
    
    if (!topicListContainer) {
      // 如果找不到容器，尝试在 document-ready 后重试
      setTimeout(() => insertSidebarIntoPage(sidebarContainer, position), 500);
      return;
    }

    const parent = topicListContainer.parentElement;
    if (!parent) return;

    // 检查是否已存在包装器
    let wrapper = parent.querySelector('.adlist-sidebar-wrapper');
    if (!wrapper) {
      // 创建包装器
      wrapper = document.createElement('div');
      wrapper.className = 'adlist-sidebar-wrapper';
      
      // 将话题列表容器包装起来
      parent.insertBefore(wrapper, topicListContainer);
      wrapper.appendChild(topicListContainer);
    }

    // 根据位置插入侧边栏
    if (position === 'right') {
      wrapper.appendChild(sidebarContainer);
      wrapper.classList.add('adlist-has-right-sidebar');
    } else {
      wrapper.insertBefore(sidebarContainer, topicListContainer);
      wrapper.classList.add('adlist-has-left-sidebar');
    }
  }

  // 从 API 获取广告内容
  function fetchAds() {
    if (!shouldShowSidebar() || !isScreenWideEnough()) {
      return;
    }

    ajax('/adlist-sidebar.json', {
      type: 'GET',
      cache: 'no-cache'
    }).then((result) => {
      if (result && result.success && result.data) {
        renderAds(result.data);
      }
    }).catch((error) => {
      console.log('[AdlistSidebar] Failed to fetch ads:', error);
    });
  }

  // 初始化
  function init() {
    if (shouldShowSidebar() && isScreenWideEnough()) {
      fetchAds();
    }
  }

  // 页面加载时初始化
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // 监听页面导航（Discourse SPA）
  api.onPageChange((url, title) => {
    setTimeout(() => {
      if (shouldShowSidebar() && isScreenWideEnough()) {
        fetchAds();
      } else {
        // 隐藏侧边栏
        const existingSidebar = document.querySelector('.adlist-sidebar-container');
        if (existingSidebar) {
          existingSidebar.remove();
        }
      }
    }, 100);
  });

  // 监听窗口大小变化
  let resizeTimeout;
  window.addEventListener('resize', () => {
    clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(() => {
      if (shouldShowSidebar() && isScreenWideEnough()) {
        fetchAds();
      } else {
        const existingSidebar = document.querySelector('.adlist-sidebar-container');
        if (existingSidebar) {
          existingSidebar.remove();
        }
      }
    }, 250);
  });
}

// HTML 转义辅助函数
function escapeHtml(text) {
  if (!text) return '';
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

// 注册插件
export default {
  name: 'adlist-sidebar',
  initialize() {
    withPluginApi('1.0.0', initializeAdlistSidebar);
  }
};
