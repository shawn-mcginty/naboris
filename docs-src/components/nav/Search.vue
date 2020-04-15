<template>
  <div class="field">
    <p class="control has-icons-left">
      <input id="search-input-text" class="input is-info is-small is-rounded" type="text" placeholder="Search" aria-label="Search">
      <span class="icon is-small is-left" style="margin-top: -4px;">
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
    window.docsearch({
      apiKey: this.apiKey,
      indexName: this.indexName,
      inputSelector: this.inputSelector,
      debug: this.debug
    });
  }
};
</script>
