import * as Cookie from 'js-cookie';

import actionLabels from '~/assets/js/main-actions';

const {
  DARK_MODE,
  LANG,
  SET_DARK_MODE,
  SET_LANGUAGE,
  SET_LOADING
} = actionLabels;

export const state = () => {
  return {
    darkMode: true,
    language: 'reason',
    loading: true
  };
};

export const mutations = {
  [SET_DARK_MODE]: (state, { darkMode }) => {
    state.darkMode = darkMode;
    return state;
  },
  [SET_LANGUAGE]: (state, { language }) => {
    state.language = language;
    return state;
  },
  [SET_LOADING]: (state, { loading }) => {
    state.loading = loading;
    return state;
  }
};

export const actions = {
  [SET_DARK_MODE]: ({ commit }, { darkMode }) => {
    Cookie.set(DARK_MODE, JSON.stringify(darkMode), { expires: 365 });

    commit({
      type: SET_DARK_MODE,
      darkMode
    });
  },
  [SET_LANGUAGE]: ({ commit }, { language }) => {
    Cookie.set(LANG, language, { expires: 365 });

    commit({
      type: SET_LANGUAGE,
      language
    });
  }
};
