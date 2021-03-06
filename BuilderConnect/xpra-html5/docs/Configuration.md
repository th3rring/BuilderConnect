The Xpra HTML5 client options are normally specified using the connect dialog form,
but all the options can also be specified as URL parameters. ie:
```
http://localhost:14500/?username=foo&keyboard_layout=fr
```


# Connection Options
|Parameter Name|Purpose|Default Value|
|--------------|-------|-------------|
|`server`      |Hostname or IP address of the xpra server to connect to|`*1`|
|`port`        |Port number of the xpra server|`*1`|
|`username`    |Authentication with the server|
|`password`    |Authentication with the server|
|`ssl`         |Enable SSL connection to the xpra server|`*1`|
|`insecure`	   |Allow sending of passwords over unencrypted connections|No|
|`path`        |The WebSocket path to connect to (usually not needed)|`*1`|
|`display`     |The display to connect to (for proxy servers)| |
|`encryption`  |To enable encryption, specify `AES`|
|`key`         |The `AES` key to use|
|`sharing`     |Allow other clients to connect to the same session|No|
|`steal`       |Take over the session and disconnect any existing client(s)|Yes|
|`reconnect`   |Automatically reconnect when the connection drops|Yes|
|`bandwidth_limit` |Bandwidth budget in bits per second|`0` (no limit)|

`*1` the default values for the server host, port and SSL status will mirror that of the connection
which was used to load the HTMl5 client (as found in the browser's URL bar), and those values don't usually need to be modified.

## Authentication
Some browsers have security features which may remove the `password`
from the URL parameters.\
This can be worked around by:
* using a secure `https` connection.
* using Javascript to keep the password value client side in
the browser's [`sessionStorage`](https://developer.mozilla.org/en-US/docs/Web/API/Window/sessionStorage) area,
just like the default connect page does.

If the authentication module used by the xpra server supports it,
authentication is done using [HMAC](https://en.wikipedia.org/wiki/HMAC) with a strong
hash function (`SHA256` or better) which means that the actual password is never sent
to the xpra server.\
By default the HTML5 client will refuse to send passwords over remote unencrypted connections.

# Features
|Parameter Name|Purpose|Default Value|
|--------------|-------|-------------|
|`keyboard`    |Enable keyboard input|Enabled unless the client does not have a mouse pointer device|
|`keyboard_layout`|The keyboard layout the client will be using|`us`|
|`clipboard`   |Enable clipboard sharing|Yes|
|`printing`    |Enable printer forwarding|Yes|
|`file_transfer`|Enable file-transfers|Yes|
|`swap_keys`   |Swap Command and Control keys|Yes on MacOS|
|`scroll_reverse_x` |Reverse X axis of the mouse pointer|No|
|`scroll_reverse_y` |Reverse Y axis of the mouse pointer|Yes on MacOS|
|`floating_menu` |Show a floating menu|Yes|
|`toolbar_position` |Default position of the toolbar (ie: `top`, `top-right`)|`top-left`|
|`autohide`    |Hide most of the toolbar until the pointer hovers over it|No|
|`sound`       |Forward audio from the server ("speaker output")|Yes|
|`video`       |Allow the use of software video decoding|Yes on 64-bit clients|

# Advanced Options
|Parameter Name|Purpose|Default Value|
|--------------|-------|-------------|
|`audio_codec` |Which audio format to use|_detected_|
|`encoding`    |Which picture encoding to use (ie: `png`, `jpeg`, `webp`, etc)|`auto`|
|`remote_logging`|Send important events to the server|Yes|
|`action`      |Connection mode (ie: `start`, `shadow`)|`connect`|
|`shadow_display`|The display to shadow if `action=shadow`|
|`submit`      |Show diagnostics when disconnecting|Yes|
|`start`       |Request the server to run this command after connecting|
|`exit_with_children` |If starting a new session, terminate it when the last start command exits|No|
|`exit_with_client`|If starting a new session, terminate it when the connection is closed|No|
