// Tor Browser → contabo tor gateway (over wireguard).
// Applied at EVERY browser startup (user.js semantics: this file wins over
// prefs.js each launch). Source of truth: dotfiles repo, placed by
// home-manager. Same recipe Kicksecure ships for gateway setups.
//
// Effect: the browser stops launching its bundled tor daemon and sends
// everything through the shared SOCKS listener on the VPS. ISP sees only
// wireguard. Trade-off (accepted): the VPS holds identity + activity.
// See vps repo: "tor gateway" block in contabo/configuration.nix.

// Don't launch the bundled tor; don't show the connection wizard
user_pref("extensions.torlauncher.start_tor", false);
user_pref("extensions.torlauncher.prompt_at_startup", false);
user_pref("extensions.torlauncher.default_bridge_type", "");

// Manual proxy = the gateway daemon on the tunnel
user_pref("network.proxy.type", 1);
user_pref("network.proxy.socks", "10.100.0.1");
user_pref("network.proxy.socks_port", 9050);
user_pref("network.proxy.socks_remote_dns", true); // DNS through the proxy — no leaks

// Torbutton: custom proxy mode (so the extension knows it's an external tor)
user_pref("extensions.torbutton.custom.socks_host", "10.100.0.1");
user_pref("extensions.torbutton.custom.socks_port", 9050);
user_pref("extensions.torbutton.inserted_button", true);
user_pref("torbrowser.settings.quickstart.enabled", true);
