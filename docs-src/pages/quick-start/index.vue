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
                  Quick Start
                </nuxt-link>
              </li>
            </ul>
          </nav>
        </section>
        <section class="section">
          <div class="content">
            <h2>
              Quick Start
            </h2>
            <p>
              Get something up and running!
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
import installation from '~/content/docs/quick-start/installation.md';
import basicserver from '~/content/docs/quick-start/basic-server.md';
import serverconfig from '~/content/docs/quick-start/server-configuration.md';
import routing from '~/content/docs/quick-start/routing.md';
import staticfiles from '~/content/docs/quick-start/static-files.md';

const imports = [
  installation,
  basicserver,
  serverconfig,
  routing,
  staticfiles
];

export default {
  data () {
    const pages = imports.map(page => ({
      attributes: page.attributes,
      meta: page.meta
    }));

    return {
      pages,
      title: 'Quick Start with naboris'
    };
  },
  methods: {
    getPermalink (page) {
      const { resourcePath } = page.meta;
      const fileName = resourcePath.replace('.md', '').split('/').pop();
      return `/quick-start/${fileName}`;
    }
  },
  head () {
    return {
      title: this.title
    };
  }
};
</script>
