<template>
  <div class="field">
    <p class="control has-icons-left search-control">
      <input id="search-input-text" class="input is-info is-small is-rounded" type="text" placeholder="Search" aria-label="Search">
      <span class="icon is-small is-left">
        <i class="fas fa-search" />
      </span>
    </p>
  </div>
</template>
<script>
export default {
  data () {
    return {
      apiKey: '80ddee898ed184e5656cc08e4bf0f986',
      indexName: 'naboris',
      inputSelector: '#search-input-text',
      debug: false
    };
  },
  mounted () {
    // eslint-disable-next-line nuxt/no-env-in-hooks
    if (process.client) {
      window.docsearch({
        apiKey: this.apiKey,
        indexName: this.indexName,
        inputSelector: this.inputSelector,
        debug: this.debug,
        transformData (hits) {
          // Transform the list of hits
          return hits
            .filter(hit => !hit.url.includes('odocs/naboris/Naboris__'))
            .sort((a, b) => {
              const aIsDocs = a.url.includes('/odocs/');
              const bIsDocs = b.url.includes('/odocs/');
              if (aIsDocs && !bIsDocs) {
                return 1;
              }

              if (bIsDocs && !aIsDocs) {
                return -1;
              }

              return 0;
            });
        }
      });
    }
  }
};
</script>
<style lang="scss">
.algolia-autocomplete + .icon.is-small.is-left {
    font-size: 0.75rem;
    height: 2.5em;
    pointer-events: none;
    position: absolute;
    top: 0;
    width: 2.5em;
    z-index: 4;
}
</style>
