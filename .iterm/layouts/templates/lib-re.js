const iTerm = Application('iTerm');
const Utils = Library('utils');

iTerm.includeStandardAdditions = true;
iTerm.activate();

function run(path, cmd) {
  const container = iTerm.createWindowWithDefaultProfile();

  const rootSession = container.currentSession;
  const bsSession = rootSession.splitHorizontallyWithDefaultProfile();
  const wpSession = bsSession.splitVerticallyWithDefaultProfile();

  Utils.prepareSessions(path, [rootSession, bsSession, wpSession]);

  rootSession.write({ text: cmd.root, newline: false });
  bsSession.write({ text: cmd.bs, newline: false });
  wpSession.write({ text: cmd.wp, newline: false });
  rootSession.select();
}
