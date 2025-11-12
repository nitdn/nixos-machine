{
  inputs,
  moduleWithSystem,
  config,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.shells = moduleWithSystem (
    {
      pkgs,
      inputs',
      ...
    }:
    {
      config,
      lib,
      ...
    }:
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user.name = "Nitesh Kumar Debnath";
          user.email = "nitkdnath@gmail.com";
        };
        settings.template-aliases.default_commit_description = ''
          "type(scope): description

          body

          Closes #NNNN
          "
        '';
      };
    }

  );
}
