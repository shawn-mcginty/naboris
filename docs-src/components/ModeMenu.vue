<template>
  <p v-if="!loading" class="fab buttons">
    <button class="button is-medium" @click="toggleDarkMode">
      <span class="icon">
        <i :class="darkModeIconClass" />
      </span>
    </button>
    <br>
    <button class="button is-medium" @click="toggleLanguage">
      <span class="icon">
        <i class="icons">
          <svg
            v-if="language === 'reason'"
            class="is-danger"
            xmlns="http://www.w3.org/2000/svg"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            aria-hidden="true"
            focusable="false"
            style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);"
            preserveAspectRatio="xMidYMid meet"
            viewBox="0 0 32 32"
          >
            <path d="M0 0v32h32V0zm15.359 29.188l-1.771-3.385h-2.391v3.385H7.999V16.922h5.505c3.255 0 5.109 1.583 5.109 4.318c0 1.854-.776 3.198-2.188 3.948l2.557 4zm15.146 0h-9.839V16.922h9.651v2.557h-6.453v2.292h5.844v2.536l-5.844.01v2.307h6.656v2.563zm-14.932-7.855c0 1.24-.745 1.906-2.042 1.906h-2.333v-3.76h2.333c1.297 0 2.042.656 2.042 1.87z" />
          </svg>
          <svg
            v-if="language === 'ocaml'"
            class="is-warning"
            xmlns="http://www.w3.org/2000/svg"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            aria-hidden="true"
            focusable="false"
            style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);"
            preserveAspectRatio="xMidYMid meet"
            viewBox="0 0 32 32"
          >
            <path d="M16.251 28.839c-.115-.224-.251-.699-.339-.901c-.095-.177-.365-.672-.496-.833c-.291-.333-.359-.359-.452-.807c-.157-.767-.537-2.115-1.011-3.057c-.251-.5-.656-.901-1.016-1.267c-.312-.312-1.031-.828-1.167-.807c-1.192.224-1.557 1.396-2.115 2.317c-.317.516-.629.943-.88 1.485c-.224.495-.203 1.057-.583 1.484a3.872 3.872 0 0 0-.833 1.464c-.048.113-.136 1.239-.251 1.504l1.755-.109c1.647.115 1.172.74 3.715.609l4.025-.135a6.212 6.212 0 0 0-.359-.948zM27.948 2.063H4.052A4.026 4.026 0 0 0 .021 6.088v8.776c.588-.203 1.395-1.437 1.667-1.733c.448-.516.541-1.193.765-1.595c.516-.948.609-1.619 1.776-1.619c.541 0 .765.129 1.125.629c.249.333.697.989.9 1.417c.251.495.631 1.145.813 1.281c.129.088.244.181.359.224c.177.067.339-.068.475-.157c.156-.135.224-.38.38-.739c.224-.521.453-1.104.583-1.328c.229-.365.319-.813.563-1.016c.365-.312.86-.339.989-.36c.745-.156 1.084.36 1.444.677c.244.224.561.651.812 1.213c.177.448.401.88.516 1.125c.088.245.317.651.448 1.145c.135.428.452.767.588.991c0 0 .203.541 1.369 1.036c.355.151.713.276 1.084.38c.516.183 1.011.161 1.64.093c.448 0 .699-.656.901-1.171c.109-.313.245-1.193.312-1.439c.068-.249-.109-.427.048-.656c.181-.244.291-.271.38-.583c.229-.699 1.489-.719 2.208-.719c.604 0 .516.583 1.531.38c.584-.109 1.147.068 1.756.249c.516.136 1.011.292 1.301.631c.183.224.657 1.328.183 1.369c.041.047.089.161.156.204c-.115.427-.563.115-.833.067c-.339-.067-.583 0-.921.157c-.584.249-1.417.229-1.932.656c-.428.359-.428 1.145-.636 1.593c0 0-.563 1.423-1.749 2.297c-.319.229-.928.765-2.229.968c-.589.089-1.147.089-1.756.068c-.291-.02-.583-.02-.88-.02c-.177 0-.765-.027-.74.041l-.067.161a.84.84 0 0 0 .041.224c.025.129.025.244.047.359c0 .245-.021.516 0 .767c.021.515.224.989.251 1.525c.02.589.312 1.219.604 1.693c.115.176.271.197.339.427c.088.245 0 .536.047.807c.156 1.057.468 2.183.943 3.152v.02c.583-.088 1.192-.312 1.959-.421c1.416-.208 3.375-.115 4.635-.229c3.199-.292 4.927 1.307 7.787.651V6.084a4.054 4.054 0 0 0-4.052-4.025zM16.021 20.964c0-.047 0-.047 0 0zm-8.614 3.687c.224-.495.359-1.031.536-1.525c.183-.475.453-1.152.921-1.396c-.061-.068-.989-.093-1.233-.115c-.271-.021-.543-.068-.813-.109a33.288 33.288 0 0 1-1.531-.317c-.292-.068-1.303-.428-1.505-.516c-.521-.224-.855-.88-1.24-.812c-.244.047-.495.135-.651.385c-.136.203-.183.561-.271.807c-.109.271-.292.541-.427.812c-.319.469-.833.896-1.057 1.371c-.048.115-.068.224-.115.339v5.421c.271.047.541.093.833.183c2.249.609 2.791.651 4.995.407l.203-.027c.156-.36.297-1.552.407-1.912c.088-.291.203-.515.249-.785c.041-.272 0-.543-.025-.787c-.043-.657.473-.88.724-1.423z" />
          </svg>
        </i>
      </span>
    </button>
  </p>
</template>
<script>
import actions from '~/assets/js/main-actions';

const {
  SET_DARK_MODE,
  SET_LANGUAGE
} = actions;

export default {
  data: () => ({}),
  computed: {
    language () {
      return this.$store.state.language;
    },
    languageIconClass () {
      const language = this.$store.state.language;
      return `icons ${language}`;
    },
    darkModeIconClass () {
      const darkMode = this.$store.state.darkMode;
      const fill = darkMode ? 'fas' : 'far';
      return `${fill} fa-lightbulb`;
    },
    loading () {
      return this.$store.state.loading;
    }
  },
  methods: {
    toggleLanguage () {
      const language = this.$store.state.language === 'reason'
        ? 'ocaml' : 'reason';
      this.$store.dispatch({
        type: SET_LANGUAGE,
        language
      });
    },
    toggleDarkMode () {
      const darkMode = !this.$store.state.darkMode;
      this.$store.dispatch({
        type: SET_DARK_MODE,
        darkMode
      });
    }
  }
};
</script>
<style lang="scss" scoped>
  .fab {
    position: fixed;
    bottom: 15px;
    right: 10px;
  }

</style>
