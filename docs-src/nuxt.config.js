import path from 'path';
import glob from 'glob';

import markdownIt from 'markdown-it';
import markdownItPrism from 'markdown-it-prism';
import Mode from 'frontmatter-markdown-loader/mode';

const plugin = (md, params) => {
  const defaultHighlight = md.options.highlight;

  md.options.highlight = (str, lang) => {
    if (!lang) {
      return str;
    }
    const langPre = `<pre class="language-${lang}"><code class="language-${lang}">`;
    let lineNum = 0;
    let newLine = '';
    const newStr = defaultHighlight(str, lang)
      .replace(langPre, `${langPre}\n`)
      .replace('\n</code></pre>', '</code></pre>')
      .replace(/\n/g, () => {
        lineNum++;
        if (lineNum > 1) {
          newLine = '\n';
        }
        return `${newLine}<span class="code-line-number">${lineNum}</span>`;
      });
    return newStr;
  };
};

function getDynamicPaths (urlFilepathTable) {
  return [].concat(
    ...Object.keys(urlFilepathTable).map((url) => {
      const filepathGlob = urlFilepathTable[url];
      return glob
        .sync(filepathGlob, { cwd: 'content' })
        .map(filepath => `${url}/${path.basename(filepath, '.md')}`);
    })
  );
}

export default {
  mode: 'universal',
  /*
  ** Headers of the page
  */
  head: {
    htmlAttrs: {
      lang: 'en'
    },
    title: process.env.npm_package_name || '',
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: process.env.npm_package_description || '' }
    ],
    link: [
      { rel: 'icon', type: 'image/png', href: '/logos/logo-color-16x16.png', sizes: '16x16' },
      { rel: 'icon', type: 'image/png', href: '/logos/logo-color-32x32.png', sizes: '32x32' },
      { rel: 'icon', type: 'image/png', href: '/logos/logo-color-96x96.png', sizes: '96x96' }
    ]
  },
  generate: {
    routes: getDynamicPaths({
      '/quick-start': 'docs/quick-start/*.md'
    })
  },
  /*
  ** Customize the progress-bar color
  */
  loading: { color: '#fff' },
  /*
  ** Global CSS
  */
  css: [
    '@/assets/sass/main.scss'
  ],
  /*
  ** Plugins to load before mounting the App
  */
  plugins: [
  ],
  /*
  ** Nuxt.js dev-modules
  */
  buildModules: [
    // Doc: https://github.com/nuxt-community/eslint-module
    '@nuxtjs/eslint-module'
  ],
  /*
  ** Nuxt.js modules
  */
  modules: [
  ],
  /*
  ** Build configuration
  */
  build: {
    postcss: {
      preset: {
        features: {
          customProperties: false
        }
      }
    },
    /*
    ** You can extend webpack config here
    */
    extend (config, ctx) {
      config.module.rules.push({
        test: /\.md$/,
        include: path.resolve(__dirname, 'content'),
        loader: 'frontmatter-markdown-loader',
        options: {
          mode: [Mode.VUE_COMPONENT, Mode.META],
          markdownIt: markdownIt({
            html: true
          }).use(markdownItPrism).use(plugin)
        }
      });
    }
  }
};
