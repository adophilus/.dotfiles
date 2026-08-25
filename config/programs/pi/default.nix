{ ... }:

{
  home.file.".pi/agent/settings.json".source = ../../../home/.pi/agent/settings.json;

  home.file.".pi/agent/agents" = {
    source = ../../../home/.pi/agent/agents;
    recursive = true;
  };

  home.file.".pi/agent/themes" = {
    source = ../../../home/.pi/agent/themes;
    recursive = true;
  };
}
