const iTerm = Application('iTerm');
const Utils = Library('utils');

iTerm.includeStandardAdditions = true;
iTerm.activate();

function run(path, cmd) {
  const container = iTerm.createWindowWithDefaultProfile();

  const rootSession = container.currentSession;
  const serverSession = rootSession.splitHorizontallyWithDefaultProfile();
  const clientSession = rootSession.splitVerticallyWithDefaultProfile();

  Utils.prepareSessions(path, [rootSession, clientSession, serverSession]);

  rootSession.write({ text: cmd.root, newline: false });
  clientSession.write({ text: cmd.client });
  serverSession.write({ text: cmd.server, newline: false });
  serverSession.select();
}
