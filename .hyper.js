module.exports = {
  config: {
    fontSize: 14,
    fontFamily: '"Source Code Pro for Powerline", Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',
    padding: '40px 40px 30px',
    colors: {},
    shell: '',
    bell: false,

    // plugins options
    paneNavigation: {
      debug: false,
      showIndicators: false,
      hotkeys: {
        navigation: {
          up: 'command+alt+up',
          down: 'command+alt+down',
          left: 'command+alt+left',
          right: 'command+alt+right'
        },
        jump_prefix: 'command+alt',
        permutation_modifier: 'shift',
      },
    },

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
    'hyper-pane',
  ],

  localPlugins: [
    'hyper-maximize-pane',
  ],
};
