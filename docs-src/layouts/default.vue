<template>
  <div class="main">
    <section>
      <NavBar />
    </section>
    <section :class="nuxtClass">
      <nuxt />
    </section>
    <Footer />
    <ModeMenu />
  </div>
</template>
<script>
import Footer from '~/components/Footer.vue';
import ModeMenu from '~/components/ModeMenu.vue';
import NavBar from '~/components/nav/NavBar.vue';

import shared from '~/assets/js/shared';

export default {
  components: {
    Footer,
    ModeMenu,
    NavBar
  },
  computed: {
    nuxtClass () {
      return {
        loading: this.$store.state.loading,
        'code-dark-mode': this.$store.state.darkMode,
        'show-reason': this.$store.state.language !== 'ocaml',
        'show-ocaml': this.$store.state.language === 'ocaml',
        'main-section': true
      };
    }
  },
  mounted () {
    shared.fetch({ store: this.$store });
  }
};
</script>
<style lang="scss" scoped>
  .main-section {
    min-height: 70vh;
  }
</style>
