function prepareSessions(path, sessions) {
  sessions.forEach(session => session.write({ text: `cd ${path}` }));
  sessions.forEach(session => session.write({ text: "clear" }));
  delay(1);
}
