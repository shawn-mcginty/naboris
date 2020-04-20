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
              <li>
                <nuxt-link to="/guides">
                  Guides
                </nuxt-link>
              </li>
              <li class="is-active">
                <nuxt-link :to="fullSlug">
                  {{ title }}
                </nuxt-link>
              </li>
            </ul>
          </nav>
        </section>
        <section class="section">
          <div class="content">
            <component :is="componentInstance" />
          </div>
        </section>
        <section class="section">
          <div class="columns">
            <div v-if="previousPage !== null" class="column">
              <a :href="previousPage.href">
                <i class="fas fa-arrow-left" />
                Previous:
                {{ previousPage.title }}
              </a>
            </div>
            <div v-if="nextPage !== null" class="column">
              <a :href="nextPage.href">
                Next:
                {{ nextPage.title }}
                <i class="fas fa-arrow-right" />
              </a>
            </div>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>
<script>
import errorHandling from '~/content/docs/guides/error-handling.md';
import middlewares from '~/content/docs/guides/middlewares.md';
import templatingEngines from '~/content/docs/guides/templating-engines.md';
import securityBestPractices from '~/content/docs/guides/security-best-practices.md';
import performanceBestPractices from '~/content/docs/guides/performance-best-practices.md';

const pages = {
  'error-handling': errorHandling,
  middlewares,
  'templating-engines': templatingEngines,
  'security-best-practices': securityBestPractices,
  'performance-best-practices': performanceBestPractices
};

export default {
  data () {
    const { page } = this.$route.params;
    const docs = pages[page];

    return {
      title: docs.attributes.title,
      page
    };
  },
  computed: {
    fullSlug () {
      return `/guides/${this.page}`;
    },
    componentInstance () {
      const docs = pages[this.page];
      return docs.vue.component;
    },
    previousPage () {
      const keys = Object.keys(pages);
      const prevIndex = keys
        .reduce((pIndex, key, i) => {
          if (key === this.page) {
            return i - 1;
          }
          return pIndex;
        }, -1);

      if (prevIndex >= 0) {
        const prevPage = keys[prevIndex];
        return {
          href: `/guides/${prevPage}`,
          title: pages[prevPage].attributes.title
        };
      }
      return null;
    },
    nextPage () {
      const keys = Object.keys(pages);
      const nextIndex = keys
        .reduce((nIndex, key, i, allKeys) => {
          if (key === this.page && allKeys.length > (i + 1)) {
            return i + 1;
          }
          return nIndex;
        }, -1);

      if (nextIndex >= 0) {
        const nextPage = keys[nextIndex];
        return {
          href: `/guides/${nextPage}`,
          title: pages[nextPage].attributes.title
        };
      }
      return null;
    }
  },
  created () {
  },
  head () {
    return {
      title: `naboris - ${this.title}`,
      meta: [
        { hid: 'description', name: 'description', content: `Guide for ${this.title} with naboris.` }
      ]
    };
  }
};
</script>
