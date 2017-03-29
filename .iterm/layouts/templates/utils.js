function prepareSessions(path, sessions) {
  const navigate = `cd ${path}`;
  const clear = 'x';

  sessions.forEach(session => session.write({ text: navigate }));
  sessions.forEach(session => session.write({ text: clear }));

  delay(1);
}
