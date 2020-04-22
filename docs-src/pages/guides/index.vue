<template>
  <div class="container">
    <div class="columns">
      <div class="column is-10 is-offset-1">
        <section class="section">
          <nav class="breadcrumb" aria-label="breadcrumbs">
            <ul>
              <li>
                <nuxt-link to="/">
                  Home
                </nuxt-link>
              </li>
              <li class="is-active">
                <nuxt-link to="/quick-start">
                  Guides
                </nuxt-link>
              </li>
            </ul>
          </nav>
        </section>
        <section class="section">
          <div class="content">
            <h2>
              Guides
            </h2>
            <p>
              Short and helpful reads.
            </p>
            <ul>
              <li v-for="page in pages" :key="page.attributes.title">
                <nuxt-link :to="getPermalink(page)">
                  {{ page.attributes.title }}
                </nuxt-link>
              </li>
            </ul>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>
<script>
import sessions from '~/content/docs/guides/sessions.md';
import errorHandling from '~/content/docs/guides/error-handling.md';
import middlewres from '~/content/docs/guides/middlewares.md';
import templatingEngines from '~/content/docs/guides/templating-engines.md';
import securityBestPractices from '~/content/docs/guides/security-best-practices.md';
import performanceBestPractices from '~/content/docs/guides/performance-best-practices.md';

const imports = [
  sessions,
  errorHandling,
  middlewres,
  templatingEngines,
  securityBestPractices,
  performanceBestPractices
];

export default {
  data () {
    const pages = imports.map(page => ({
      attributes: page.attributes,
      meta: page.meta
    }));

    return {
      pages,
      title: 'Guides for naboris'
    };
  },
  methods: {
    getPermalink (page) {
      const { resourcePath } = page.meta;
      const fileName = resourcePath.replace('.md', '').split('/').pop();
      return `/guides/${fileName}`;
    }
  },
  head () {
    return {
      title: this.title,
      meta: [
        { hid: 'description', name: 'description', content: 'Guides to help you learn to use naboris.' }
      ]
    };
  }
};
</script>
