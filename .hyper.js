module.exports = {
  config: {
    fontSize: 14,
    fontFamily: '"Source Code Pro", Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',
    padding: '40px 40px 30px',
    colors: {},
    shell: '',
    bell: false,

    // plugins options
    hyperStatusLine: {
      footerTransparent: true,
    },
  },

  plugins: [
    // theme
    'hyper-hybrid-theme',

    // extensions
    'hypercwd',
    'hyperfull',
    'hyperminimal',
    'hyper-statusline',
  ],

  localPlugins: [
    'hyper-maximize-pane',
  ],
};
