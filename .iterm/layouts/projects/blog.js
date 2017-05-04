#!/usr/bin/env osascript -l JavaScript

function run() {
  const Blog = Library('blog');

  Blog.run('~/Dev/Projects/alexfedoseev.com/blog', {
    root: 'git status',
    server: 'docker-compose up',
  });
}
