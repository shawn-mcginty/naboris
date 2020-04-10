<template>
  <div>
    <section class="hero is-medium is-light is-bold">
      <div class="hero-body main-hero">
        <div class="container">
          <h1 class="title">
            naboris <span class="version-number is-size-7 is-family-code">{{ version }}</span>
          </h1>
          <h2 class="subtitle">
            {{ packageDescription }}
          </h2>
        </div>
      </div>
    </section>
    <section class="notices v-space">
      <div class="container">
        <div class="columns is-mobile">
          <div class="column is-half-desktop is-offset-one-quarter-desktop is-10-tablet is-offset-1-tablet is-10-mobile is-offset-1-mobile">
            <article class="message">
              <div class="message-header">
                <p>Still Pre-alpha!</p>
              </div>
              <div class="message-body">
                Thanks for checking out <strong>naboris</strong>! It is important to keep in mind that naboris is still in early stages of development. No formal or real-world testing has yet been done! However, please feel free to install naboris and report any bugs or feature requests. The library is constantly pushing toward a more hardened and full-featured 1.0.0 release.
              </div>
            </article>
          </div>
        </div>
        <Scaffolding />
      </div>
    </section>
    <section class="section sell-it has-background-grey-lighter">
      <div class="container is-fluid">
        <div class="tile is-ancestor">
          <div class="tile is-vertical is-8">
            <div class="tile">
              <div class="tile is-parent">
                <article class="tile is-child box">
                  <div class="content">
                    <h4>🍰 Simple</h4>
                    <p>
                      naboris makes it easy to get an http server up and running.
                      Handle requests with only a few lines of code. The naboris API tries
                      to stay out of your way.
                    </p>
                  </div>
                </article>
              </div>
              <div class="tile is-parent">
                <article class="tile is-child box">
                  <div class="content">
                    <h4>🖥 Web Apps</h4>
                    <p>
                      Serve static files with the greatest of ease.
                      Deliver dynamic content to your hearts content.
                      Mightily manage your users sessions.
                    </p>
                  </div>
                </article>
              </div>
            </div>
            <div class="tile is-parent">
              <article class="tile is-child box">
                <div class="content">
                  <h4>🏗 Extensible</h4>
                  <p>
                    Using a lightweight API and following a middleware pattern makes
                    it easy to create tools and libraries for use with naboris. Add middleware
                    for protecting certain endpoints from unauthorized useres, encode/decode
                    request data, verify request headers, request/reponse logging, you name it!
                  </p>
                </div>
              </article>
            </div>
          </div>
          <div class="tile is-parent">
            <article class="tile is-child box">
              <div class="content">
                <h4>🐫 OCaml/ReasonML</h4>
                <p>
                  Multi-paradigm goodness: functional, imperative, and object-oritented,
                  oh my!
                </p>
                <p>
                  Program correctness: find and squash bugs fast!
                </p>
                <p>
                  Beautiful type system: expressive types make writing flexible
                  and readable code a breeze.
                </p>
                <p>
                  Blazing fast compile times: stop waiting on code to build!
                </p>
              </div>
            </article>
          </div>
        </div>
      </div>
    </section>
    <section class="hero is-medium is-dark is-bold">
      <div class="hero-body">
        <div class="container">
          <div class="columns is-vcentered">
            <div class="column has-text-right">
              <h3 class="title">
                Newsletter
              </h3>
              <h2 class="subtitle">
                Get email updates.
              </h2>
            </div>
            <div class="column">
              <form action="https://mail.shawnmcginty.com/subscribe" method="POST" accept-charset="utf-8">
                <div class="field has-addons">
                  <div class="control">
                    <input class="input" type="email" placeholder="smarty@coolorg.com" aria-label="Input email for newsletter" required>
                  </div>
                  <div class="control">
                    <button class="button is-info" aria-label="Sign up for newsletter">
                      Sign Up
                    </button>
                  </div>
                </div>
              </form>
              <p class="help">
                Only releases and major updates. No spam.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
<script>
import scaffolding from '~/content/docs/scaffolding.md';

const docsPackage = require('~assets/../../package.json');
const parentPackage = require('~assets/../../../package.json');

const Scaffolding = scaffolding.vue.component;

export default {
  components: {
    Scaffolding
  },
  data () {
    return {
      packageDescription: docsPackage.description,
      version: parentPackage.version,
      title: `naboris ${docsPackage.description}`
    };
  },
  head () {
    return {
      title: this.title
    };
  }
};
</script>

<style lang="scss">
  @import "~assets/sass/main.scss";

  .v-space {
    margin-top: 25px;
    padding-bottom: 25px;
  }
</style>
