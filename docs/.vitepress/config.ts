import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Enterprise Data Platform',
  description: 'Documentation for the Enterprise Data Platform.',
  cleanUrls: true,
  sitemap: {
    hostname: 'https://edp.mcguire.technology/'
  },
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/favicon-32x32.png' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/favicon-16x16.png' }],
    ['link', { rel: 'apple-touch-icon', sizes: '180x180', href: '/apple-touch-icon.png' }],
    ['link', { rel: 'manifest', href: '/site.webmanifest' }],
    ['meta', { name: 'theme-color', content: '#071525' }],
    ['meta', { property: 'og:image', content: 'https://edp.mcguire.technology/brand/png/wordmark-dark-1200.png' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }]
  ],
  themeConfig: {
    logo: '/logo.svg',
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Architecture', link: '/architecture/' },
      { text: 'GRC', link: '/grc/' },
      { text: 'Source Systems', link: '/source-systems/' },
      { text: 'Changelog', link: '/changelog' },
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
          { text: 'Implementation Planning', link: '/guide/implementation-planning' },
          { text: 'Branding', link: '/branding' },
          { text: 'Changelog', link: '/changelog' }
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
          { text: 'GRC', link: '/grc/' },
          { text: 'Policy Template Conversion', link: '/grc/policy-template-conversion' },
          { text: 'Runbooks', link: '/runbooks/' },
          { text: 'Local PostgreSQL', link: '/runbooks/local-postgresql' },
          { text: 'Local Airflow', link: '/runbooks/local-airflow' },
          { text: 'Local Superset', link: '/runbooks/local-superset' },
          { text: 'Decisions', link: '/decisions/' }
        ]
      },
      {
        text: 'Source Systems',
        items: [
          { text: 'Overview', link: '/source-systems/' },
          { text: 'Active Directory', link: '/source-systems/active-directory' },
          { text: 'Microsoft 365', link: '/source-systems/microsoft-365' },
          { text: 'Google Workspace', link: '/source-systems/google-workspace' },
          { text: 'Infinite Campus', link: '/source-systems/infinite-campus' },
          { text: 'Canvas LMS', link: '/source-systems/canvas-lms' },
          { text: 'Follett Destiny', link: '/source-systems/follett-destiny' },
          { text: 'Apple Business and School Manager', link: '/source-systems/apple-business-school-manager' },
          { text: 'KnowBe4', link: '/source-systems/knowbe4' },
          { text: 'Cisco Meraki Dashboard', link: '/source-systems/cisco-meraki-dashboard' },
          { text: 'ManageEngine ServiceDesk Plus', link: '/source-systems/manageengine-servicedesk-plus' },
          { text: 'ManageEngine Endpoint Central', link: '/source-systems/manageengine-endpoint-central' },
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
