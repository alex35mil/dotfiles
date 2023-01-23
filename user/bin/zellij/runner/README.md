# zellij-runner
Ad-hoc replacement of Zellij session switcher (which doesn't exist yet).

```shell
# run switcher in interactive mode
zellij-runner

# create/connect to specified session
zellij-runner my-session

# create session with specified layout
zellij-runner my-session my-layout
```

To optimize autocompletion when switching working dir, set the following environment variables:

```shell
# directory with the projects, relative to the HOME dir
ZELLIJ_RUNNER_ROOT_DIR=Projects

# switcher respects gitignore, but in case there's no git
ZELLIJ_RUNNER_IGNORE_DIRS=node_modules,target

# traverse dirs 3 level max from ZELLIJ_RUNNER_ROOT_DIR
ZELLIJ_RUNNER_MAX_DIRS_DEPTH=3
```
