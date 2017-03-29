const iTerm = Application('iTerm');
const Utils = Library('utils');

iTerm.includeStandardAdditions = true;
iTerm.activate();

function run(path, cmd) {
  const container = iTerm.createWindowWithDefaultProfile();

  const vimSession = container.currentSession;
  const cliSession = vimSession.splitHorizontallyWithDefaultProfile();

  Utils.prepareSessions(path, [
    vimSession,
    cliSession,
  ]);

  vimSession.write({ text: cmd.vim });
  cliSession.write({ text: cmd.cli });
}
