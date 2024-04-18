# zellij-statusbar
Minimal statusbar plugin for Zellij.

<img width="1728" alt="Terminal multiplexer" src="https://user-images.githubusercontent.com/4244251/213017876-62a7a987-c0ac-4515-87db-df1c809351ef.png">

## Installation
I didn't publish it anywhere, so you can pull this repo and build it from source.

Checkout [my install script](../../../script/install.sh) and [zellij config](../../../home/.config/zellij/) for details.

NOTE: On the first run, `zellij` asks the permission to run the plugin. Navigate to the plugin pane (it should be selectable) and hit `y`. You might need to restart the session for plugin to function properly.
Make sure to have rust and the `wasm32-wasi` target installed.
You can run this command `rustup target add wasm32-wasi` to install it.
