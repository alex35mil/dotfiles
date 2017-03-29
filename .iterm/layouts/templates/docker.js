const iTerm = Application('iTerm');
const Utils = Library('utils');

iTerm.includeStandardAdditions = true;
iTerm.activate();

function run(path, cmd) {
  const container = iTerm.createWindowWithDefaultProfile();

  const webSession = container.currentSession;
  const serversSession = webSession.splitVerticallyWithDefaultProfile();
  const apiSession = webSession.splitHorizontallyWithDefaultProfile();

  Utils.prepareSessions(path, [
    webSession,
    apiSession,
    serversSession,
  ]);

  webSession.write({ text: cmd.web });
  apiSession.write({ text: cmd.api });
  serversSession.write({ text: cmd.servers });
}
