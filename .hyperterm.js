module.exports = {
  config: {
    // default font size in pixels for all tabs
    fontSize: 14,

    // font family with optional fallbacks
    fontFamily: '"Source Code Pro", Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',

    // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
    cursorColor: 'rgba(255, 255, 255, .4)',

    // `BEAM` for |, `UNDERLINE` for _, `BLOCK` for █
    cursorShape: 'BLOCK',

    // color of the text
    foregroundColor: '#d5c4a1', // original: '#c4c8c6'

    // terminal background color
    backgroundColor: '#1d1f21',

    // border color (window, tabs)
    borderColor: '#1d1f21',

    // custom css to embed in the main window
    css: '',

    // custom css to embed in the terminal window
    termCSS: `
      x-screen {
        -webkit-font-smoothing: subpixel-antialiased !important;
      }
    `,

    // custom padding (css format, i.e.: `top right bottom left`)
    padding: '30px',

    // the full list. if you're going to provide the full color palette,
    // including the 6 x 6 color cubes and the grayscale map, just provide
    // an array here instead of a color map object
    colors: {
      black: '#383d43',
      red: '#c66363',
      green: '#c0c86d',
      yellow: '#eac171',
      blue: '#80a2be',
      magenta: '#b193ba',
      cyan: '#90c9c1',
      white: '#c2c5c3',
      lightBlack: '#636363',
      lightRed: '#a04041',
      lightGreen: '#8b9440',
      lightYellow: '#ec9c62',
      lightBlue: '#5d7f9a',
      lightMagenta: '#82658c',
      lightCyan: '#5e8d87',
      lightWhite: '#6d757d'
    },

    // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
    // if left empty, your system's login shell will be used by default
    shell: '',

    // for advanced config flags please refer to https://hyperterm.org/#cfg
    hyperclean: {
      hideTabs: true,
    },
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hyperpower`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: [
    'hyperclean',
    'hypercwd',
  ],

  // in development, you can create a directory under
  // `~/.hyperterm_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: [
    'hyperterm-plugin-scaffold',
    'hyperterm-plugin-set-title',
    'hyperterm-plugin-new-window',
    'hyperterm-plugin-clear-new-window',
  ]
};
