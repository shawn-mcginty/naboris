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
    <!-- Matomo -->
    <script type="text/javascript">
      var _paq = window._paq || [];
      /* tracker methods like 'setCustomDimension' should be called before 'trackPageView' */
      _paq.push(['trackPageView']);
      _paq.push(['enableLinkTracking']);
      (function() {
      var u='//matomo.shawnmcginty.com/';
      _paq.push(['setTrackerUrl', u+'matomo.php']);
      _paq.push(['setSiteId', '2']);
      var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
      g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
      })();
    </script>
    <!-- End Matomo Code -->
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
