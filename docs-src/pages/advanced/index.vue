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
                <nuxt-link to="/advanced">
                  Advanced
                </nuxt-link>
              </li>
            </ul>
          </nav>
        </section>
        <section class="section">
          <div class="content">
            <h2>
              🚜 Under Construction ⛔
            </h2>
            <p>
              Advanced use guides are currently being written and will be published
              soon.
            </p>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  data () {
    return {
      title: 'Advanced naboris usage'
    };
  },
  head () {
    return {
      title: this.title,
      meta: [
        { hid: 'description', name: 'description', content: 'Advanced usage guides for naboris.' }
      ]
    };
  }
};
</script>
