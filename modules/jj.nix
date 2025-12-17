{
  moduleWithSystem,
  ...
}:
{
  flake.modules.homeManager.shells = moduleWithSystem (
    _: _: {
      programs.jujutsu = {
        enable = true;
        settings = {
          user.name = "Nitesh Kumar Debnath";
          user.email = "nitkdnath@gmail.com";
        };
        settings.templates.draft_commit_description = ''
          concat(
          builtin_draft_commit_description,
          "
          JJ:  ### Types
          JJ:  - Changes relevant to the API or UI:
          JJ:    - `feat` Commits that add, adjust or remove a new feature to the API or UI
          JJ:    - `fix` Commits that fix an API or UI bug of a preceded `feat` commit
          JJ:    - `refactor` Commits that rewrite or restructure code without altering API or UI behavior
          JJ:    - `perf` Commits are special type of `refactor` commits that specifically improve performance
          JJ:    - `style` Commits that address code style (e.g., white-space, formatting, missing semi-colons) and do not affect application behavior
          JJ:    - `test` Commits that add missing tests or correct existing ones
          JJ:    - `docs` Commits that exclusively affect documentation
          JJ:    - `build` Commits that affect build-related components such as build tools, dependencies, project version, ...
          JJ:    - `ops` Commits that affect operational aspects like infrastructure (IaC), deployment scripts, CI/CD pipelines, backups, monitoring, or recovery procedures, ...
          JJ:    - `chore` Commits that represent tasks like initial commit, modifying `.gitignore`, ...
          ",
          )
        '';
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
