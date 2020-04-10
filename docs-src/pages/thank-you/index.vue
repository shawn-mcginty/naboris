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
                <nuxt-link to="/thank-you">
                  Thank You!
                </nuxt-link>
              </li>
            </ul>
          </nav>
        </section>
        <section class="section">
          <div class="content">
            <h2>
              Thank You!
            </h2>
            <p>
              Thanks for signing up for the Naboris newsletter.
              This will help you keep up to date with new features and releases.
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
      title: 'Thank You!'
    };
  },
  head () {
    return {
      title: this.title
    };
  }
};
</script>
