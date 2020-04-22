import * as Cookie from 'js-cookie';

import actions from '~/assets/js/main-actions';

const {
  SET_LANGUAGE,
  SET_DARK_MODE,
  DARK_MODE,
  LANG,
  SET_LOADING
} = actions;

export default {
  fetch ({ store }) {
    const {
      commit,
      state
    } = store;
    const {
      language,
      darkMode
    } = state;

    const storedLanguage = Cookie.get(LANG);
    const storedDarkModeStr = Cookie.get(DARK_MODE);

    // eslint-disable-next-line no-console
    console.log({
      storedDarkModeStr,
      storedLanguage,
      state: JSON.stringify(state)
    });
    if (storedLanguage !== undefined && storedLanguage !== language) {
      commit({
        type: SET_LANGUAGE,
        language: storedLanguage
      });
    }

    if (storedDarkModeStr) {
      try {
        const storedDarkMode = JSON.parse(storedDarkModeStr);
        if (storedDarkMode !== darkMode) {
          commit({
            type: SET_DARK_MODE,
            darkMode: storedDarkMode
          });
        }
      } catch (e) {
        // eslint-disable-next-line no-console
        console.error(e);
      }
    }

    commit({
      type: SET_LOADING,
      loading: false
    });
  }
};
