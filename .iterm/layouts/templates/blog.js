const iTerm = Application('iTerm');
const Utils = Library('utils');

iTerm.includeStandardAdditions = true;
iTerm.activate();

function run(path, cmd) {
  const container = iTerm.createWindowWithDefaultProfile();

  const rootSession = container.currentSession;
  const serverSession = rootSession.splitHorizontallyWithDefaultProfile();

  Utils.prepareSessions(path, [
    rootSession,
    serverSession,
  ]);

  rootSession.write({ text: cmd.root });
  serverSession.write({ text: cmd.server });
}
