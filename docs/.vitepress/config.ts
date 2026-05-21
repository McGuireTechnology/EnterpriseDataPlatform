import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Enterprise Data Platform',
  description: 'Documentation for the Enterprise Data Platform.',
  cleanUrls: true,
  sitemap: {
    hostname: 'https://edp.mcguire.technology/'
  },
  themeConfig: {
    logo: '/logo.svg',
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Architecture', link: '/architecture/' },
      { text: 'Source Systems', link: '/source-systems/' },
      { text: 'Positioning', link: '/architecture/platform-positioning' },
      { text: 'Runbooks', link: '/runbooks/' },
      { text: 'Decisions', link: '/decisions/' }
    ],
    sidebar: [
      {
        text: 'Guide',
        items: [
          { text: 'Getting Started', link: '/guide/getting-started' },
          { text: 'Platform Charter', link: '/guide/platform-charter' },
          { text: 'Implementation Planning', link: '/guide/implementation-planning' }
        ]
      },
      {
        text: 'Platform',
        items: [
          { text: 'Architecture', link: '/architecture/' },
          { text: 'Runtime Infrastructure', link: '/architecture/runtime-infrastructure' },
          { text: 'Data Lifecycle', link: '/architecture/data-lifecycle' },
          { text: 'Data Persistence', link: '/architecture/data-persistence' },
          { text: 'Orchestration', link: '/architecture/orchestration' },
          { text: 'Consumer Tools', link: '/architecture/consumer-tools' },
          { text: 'Tool Categories', link: '/architecture/tool-categories' },
          { text: 'Tooling Recommendations', link: '/architecture/tooling-recommendations' },
          { text: 'Platform Positioning', link: '/architecture/platform-positioning' },
          { text: 'Runbooks', link: '/runbooks/' },
          { text: 'Decisions', link: '/decisions/' }
        ]
      },
      {
        text: 'Source Systems',
        items: [
          { text: 'Overview', link: '/source-systems/' },
          { text: 'Active Directory', link: '/source-systems/active-directory' },
          { text: 'Microsoft 365', link: '/source-systems/microsoft-365' },
          { text: 'Common Systems', link: '/source-systems/common-systems' },
          { text: 'Inventory', link: '/source-systems/inventory' },
          { text: 'Connector Catalog', link: '/source-systems/connector-catalog' },
          { text: 'Connector Standard', link: '/source-systems/connector-standard' }
        ]
      }
    ],
    search: {
      provider: 'local'
    },
    socialLinks: []
  }
})
