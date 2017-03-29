const iTerm = Application('iTerm');
const Utils = Library('utils');

iTerm.includeStandardAdditions = true;
iTerm.activate();

function run(path, cmd) {
  const container = iTerm.createWindowWithDefaultProfile();

  const clientSession = container.currentSession;
  const clientServerSession = clientSession.splitHorizontallyWithDefaultProfile();
  const apiSession = clientSession.splitVerticallyWithDefaultProfile();
  const apiServerSession = clientServerSession.splitVerticallyWithDefaultProfile();

  Utils.prepareSessions(path, [
    clientSession,
    apiSession,
    clientServerSession,
    apiServerSession,
  ]);

  clientSession.write({ text: cmd.client });
  apiSession.write({ text: cmd.api });
  clientServerSession.write({ text: cmd.clientServer });
  apiServerSession.write({ text: cmd.apiServer });
}
