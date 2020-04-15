<template>
  <nav class="navbar is-primary is-fixed-top" role="navigation" aria-label="main navigation">
    <div class="navbar-brand">
      <a href="/" class="navbar-item">
        <NaborisLogo class="naboris-svg" />
        naboris
      </a>

      <div
        :class="hambergerButtonClass"
        aria-label="menu"
        aria-expanded="false"
        data-target="navbarBasicExample"
        @click="toggleHambergerMenu"
      >
        <span aria-hidden="true" />
        <span aria-hidden="true" />
        <span aria-hidden="true" />
      </div>
    </div>

    <div id="naboris-navbar-menu" :class="navbarMenuClass">
      <div class="navbar-end">
        <div class="navbar-item">
          <Search style="margin-bottom: 0px" />
        </div>
        <a href="/" class="navbar-item">
          Home
        </a>
        <div class="navbar-item has-dropdown is-hoverable">
          <a class="navbar-link" href="/quick-start">
            Quick Start
          </a>

          <div class="navbar-dropdown">
            <a class="navbar-item" href="/quick-start/installation">
              Installation
            </a>
            <a class="navbar-item" href="/quick-start/basic-server">
              Basic Server
            </a>
            <a class="navbar-item" href="/quick-start/routing">
              Routing
            </a>
            <a class="navbar-item" href="/quick-start/static-files">
              Static files
            </a>
          </div>
        </div>
        <a class="navbar-item" href="/guides">
          Guides
        </a>
        <a class="navbar-item" href="/odocs">
          Docs
        </a>
        <a class="navbar-item" href="/advanced">
          Advanced
        </a>
        <a class="navbar-item" href="https://github.com/shawn-mcginty/naboris">
          GitHub
        </a>
        <div class="nabvar-item navbar-spacer" />
      </div>
    </div>
  </nav>
</template>
<script>
import NaborisLogo from '../NaborisLogo';
import Search from './Search';

export default {
  components: {
    NaborisLogo,
    Search
  },
  data () {
    return {
      showHambergerMenu: false
    };
  },
  computed: {
    hambergerButtonClass () {
      return {
        'navbar-burger': true,
        burger: true,
        'is-active': this.showHambergerMenu
      };
    },
    navbarMenuClass () {
      return {
        'navbar-menu': true,
        'is-active': this.showHambergerMenu
      };
    }
  },
  methods: {
    toggleHambergerMenu () {
      this.showHambergerMenu = !this.showHambergerMenu;
    }
  }
};
</script>
