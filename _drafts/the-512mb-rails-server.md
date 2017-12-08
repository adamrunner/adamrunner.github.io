---
layout: post
title: The 512MB RAM Rails Server (and why it's not good)
---

Trying out a rails server on 512mb of RAM
Weird errors, lets enable swap and try again...

Oh wait, they're gone now.


Based on a true story...
~~~
$ bundle exec cap production deploy --trace
** Invoke production (first_time)
** Execute production
** Invoke load:defaults (first_time)
** Execute load:defaults
** Invoke bundler:map_bins (first_time)
** Invoke passenger:bundler:hook (first_time)
** Execute passenger:bundler:hook
** Execute bundler:map_bins
** Invoke deploy:set_rails_env (first_time)
** Execute deploy:set_rails_env
** Invoke deploy:set_linked_dirs (first_time)
** Execute deploy:set_linked_dirs
** Invoke deploy:set_rails_env
** Invoke rbenv:validate (first_time)
** Execute rbenv:validate
** Invoke rbenv:map_bins (first_time)
** Invoke passenger:rbenv:hook (first_time)
** Invoke passenger:test_which_passenger (first_time)
** Execute passenger:test_which_passenger
** Execute passenger:rbenv:hook
** Execute rbenv:map_bins
** Invoke deploy (first_time)
** Execute deploy
** Invoke deploy:starting (first_time)
** Execute deploy:starting
** Invoke deploy:check (first_time)
** Invoke git:check (first_time)
** Invoke git:wrapper (first_time)
** Execute git:wrapper
00:00 git:wrapper
      01 mkdir -p /tmp
    ✔ 01 user@example.com 0.073s
      Uploading /tmp/git-ssh-example-production-example.sh 100.0%
      02 chmod 700 /tmp/git-ssh-example-production-example.sh
    ✔ 02 user@example.com 0.075s
** Execute git:check
00:00 git:check
      01 git ls-remote git@github.com:example/myapp.git HEAD
      01 a4487e9a7887d0c938f064900a42194b0f8f9e54	HEAD
    ✔ 01 user@example.com 1.228s
** Execute deploy:check
** Invoke deploy:check:directories (first_time)
** Execute deploy:check:directories
00:01 deploy:check:directories
      01 mkdir -p /var/www/example.com/shared /var/www/example.com/releases
    ✔ 01 user@example.com 0.082s
** Invoke deploy:check:linked_dirs (first_time)
** Execute deploy:check:linked_dirs
00:01 deploy:check:linked_dirs
      01 mkdir -p /var/www/example.com/shared/log /var/www/example.com/shared/tmp/pids /var/www/example.com/shared/tmp/cache /var/www/example.com/shared/tmp/sockets …
    ✔ 01 user@example.com 0.079s
** Invoke deploy:check:make_linked_dirs (first_time)
** Execute deploy:check:make_linked_dirs
** Invoke deploy:check:linked_files (first_time)
** Execute deploy:check:linked_files
** Invoke deploy:set_previous_revision (first_time)
** Execute deploy:set_previous_revision
** Invoke deploy:started (first_time)
** Execute deploy:started
** Invoke deploy:updating (first_time)
** Invoke deploy:new_release_path (first_time)
** Execute deploy:new_release_path
** Invoke git:create_release (first_time)
** Invoke git:update (first_time)
** Invoke git:clone (first_time)
** Invoke git:wrapper
** Execute git:clone
00:01 git:clone
      The repository mirror is at /var/www/example.com/repo
** Execute git:update
00:02 git:update
      01 git remote set-url origin git@github.com:example/myapp.git
    ✔ 01 user@example.com 0.082s
      02 git remote update --prune
      02 Fetching origin
    ✔ 02 user@example.com 1.159s
** Execute git:create_release
00:03 git:create_release
      01 mkdir -p /var/www/example.com/releases/20170218190810
    ✔ 01 user@example.com 0.078s
      02 git archive master | /usr/bin/env tar -x -f - -C /var/www/example.com/releases/20170218190810
    ✔ 02 user@example.com 0.108s
** Execute deploy:updating
** Invoke deploy:set_current_revision (first_time)
** Invoke git:set_current_revision (first_time)
** Execute git:set_current_revision
** Execute deploy:set_current_revision
00:03 deploy:set_current_revision
      01 echo "7d0c938fa4487e9a78f9e5488064a42194b0f900" >> REVISION
    ✔ 01 user@example.com 0.079s
** Invoke deploy:symlink:shared (first_time)
** Execute deploy:symlink:shared
** Invoke deploy:symlink:linked_files (first_time)
** Execute deploy:symlink:linked_files
** Invoke deploy:symlink:linked_dirs (first_time)
** Execute deploy:symlink:linked_dirs
00:03 deploy:symlink:linked_dirs
      01 mkdir -p /var/www/example.com/releases/20170218190810 /var/www/example.com/releases/20170218190810/tmp /var/www/example.com/releases/20170218190810/vendor /var…
    ✔ 01 user@example.com 0.081s
      02 rm -rf /var/www/example.com/releases/20170218190810/log
    ✔ 02 user@example.com 0.077s
      03 ln -s /var/www/example.com/shared/log /var/www/example.com/releases/20170218190810/log
    ✔ 03 user@example.com 0.075s
      04 ln -s /var/www/example.com/shared/tmp/pids /var/www/example.com/releases/20170218190810/tmp/pids
    ✔ 04 user@example.com 0.074s
      05 ln -s /var/www/example.com/shared/tmp/cache /var/www/example.com/releases/20170218190810/tmp/cache
    ✔ 05 user@example.com 0.075s
      06 ln -s /var/www/example.com/shared/tmp/sockets /var/www/example.com/releases/20170218190810/tmp/sockets
    ✔ 06 user@example.com 0.074s
      07 ln -s /var/www/example.com/shared/vendor/bundle /var/www/example.com/releases/20170218190810/vendor/bundle
    ✔ 07 user@example.com 0.073s
      08 ln -s /var/www/example.com/shared/public/system /var/www/example.com/releases/20170218190810/public/system
    ✔ 08 user@example.com 0.075s
      09 ln -s /var/www/example.com/shared/public/uploads /var/www/example.com/releases/20170218190810/public/uploads
    ✔ 09 user@example.com 0.077s
      10 ln -s /var/www/example.com/shared/public/assets /var/www/example.com/releases/20170218190810/public/assets
    ✔ 10 user@example.com 0.073s
** Invoke deploy:updated (first_time)
** Invoke bundler:install (first_time)
** Execute bundler:install
00:05 bundler:install
      01 $HOME/.rbenv/bin/rbenv exec bundle install --path /var/www/example.com/shared/bundle --without development test --deployment --quiet
      01 bash: line 1: 29013 Killed                  $HOME/.rbenv/bin/rbenv exec bundle install --path /var/www/example.com/shared/bundle --without development test --deploym…
cap aborted!
SSHKit::Runner::ExecuteError: Exception while executing as user@example.com: bundle exit status: 137
bundle stdout: Nothing written
bundle stderr: bash: line 1: 29013 Killed                  $HOME/.rbenv/bin/rbenv exec bundle install --path /var/www/example.com/shared/bundle --without development test --deployment --quiet
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/runners/parallel.rb:15:in `rescue in block (2 levels) in execute'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/runners/parallel.rb:11:in `block (2 levels) in execute'
SSHKit::Command::Failed: bundle exit status: 137
bundle stdout: Nothing written
bundle stderr: bash: line 1: 29013 Killed                  $HOME/.rbenv/bin/rbenv exec bundle install --path /var/www/example.com/shared/bundle --without development test --deployment --quiet
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/command.rb:100:in `exit_status='
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/backends/netssh.rb:148:in `execute_command'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/backends/abstract.rb:141:in `block in create_command_and_execute'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/backends/abstract.rb:141:in `tap'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/backends/abstract.rb:141:in `create_command_and_execute'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/backends/abstract.rb:74:in `execute'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/capistrano-bundler-1.1.4/lib/capistrano/tasks/bundler.cap:35:in `block (5 levels) in <top (required)>'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/backends/abstract.rb:93:in `with'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/capistrano-bundler-1.1.4/lib/capistrano/tasks/bundler.cap:26:in `block (4 levels) in <top (required)>'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/backends/abstract.rb:85:in `within'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/capistrano-bundler-1.1.4/lib/capistrano/tasks/bundler.cap:25:in `block (3 levels) in <top (required)>'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/backends/abstract.rb:29:in `instance_exec'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/backends/abstract.rb:29:in `run'
/usr/local/var/rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/sshkit-1.12.0/lib/sshkit/runners/parallel.rb:12:in `block (2 levels) in execute'
Tasks: TOP => deploy:updated => bundler:install
The deploy has failed with an error: Exception while executing as user@example.com: bundle exit status: 137
bundle stdout: Nothing written
bundle stderr: bash: line 1: 29013 Killed                  $HOME/.rbenv/bin/rbenv exec bundle install --path /var/www/example.com/shared/bundle --without development test --deployment --quiet
** Invoke deploy:failed (first_time)
** Execute deploy:failed


** DEPLOY FAILED
...
~~~
