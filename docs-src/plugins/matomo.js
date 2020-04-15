export default ({ app }) => {
  if (process.env.NODE_ENV !== 'production') return
  // Matomo
  window._paq = window._paq || [];
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  window._paq.push(['trackPageView']);
  window._paq.push(['enableLinkTracking']);
  (function() {
    var u="//matomo.shawnmcginty.com/";
    window._paq.push(['setTrackerUrl', u+'matomo.php']);
    window._paq.push(['setSiteId', '2']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
  })();
  // End Matomo Code
};
