// Tor Browser → contabo tor gateway (over wireguard).
// Applied at EVERY browser startup (user.js semantics: this file wins over
// prefs.js each launch). Source of truth: dotfiles repo, placed by
// home-manager — shared by zenith (Linux) and nadir (darwin).
//
// Effect: the browser routes everything through the shared SOCKS listener
// on the VPS. ISP sees only wireguard. Trade-off (accepted): the VPS holds
// identity + activity. See vps repo: "tor gateway" block in
// contabo/configuration.nix.
//
// Modern TorSettings prefs (per TorSettings.sys.mjs; TorProxyType:
// Socks4=0, Socks5=1, HTTPS=2). Replaces the legacy torlauncher/torbutton/
// network.proxy recipe. Verified working 2026-09-06 on nadir (lsof + GETCONF).
user_pref("torbrowser.settings.proxy.enabled", true);
user_pref("torbrowser.settings.proxy.type", 1);
user_pref("torbrowser.settings.proxy.address", "10.100.0.1");
user_pref("torbrowser.settings.proxy.port", 1080);
user_pref("torbrowser.settings.proxy.username", "");
user_pref("torbrowser.settings.proxy.password", "");
