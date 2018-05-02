const iTerm = Application('iTerm');
const Utils = Library('utils');

iTerm.includeStandardAdditions = true;
iTerm.activate();

function run(path, cmd) {
  const container = iTerm.createWindowWithDefaultProfile();

  const rootSession = container.currentSession;
  const watcherSession = rootSession.splitHorizontallyWithDefaultProfile();

  Utils.prepareSessions(path, [rootSession, watcherSession]);

  rootSession.write({ text: cmd.root, newline: false });
  watcherSession.write({ text: cmd.watcher, newline: false });
  rootSession.select();
}
