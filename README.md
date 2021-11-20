# docker-vault-rspec

An example repo showing how Docker tests can be directly integrated in rspec tests. 

In this case, we can test the Vault gem against a running Vault instance.

## Example 

```
/Users/peter.souter/.rbenv/versions/2.7.3/bin/ruby -I/Users/peter.souter/.rbenv/versions/2.7.3/lib/ruby/gems/2.7.0/gems/rspec-core-3.7.1/lib:/Users/peter.souter/.rbenv/versions/2.7.3/lib/ruby/gems/2.7.0/gems/rspec-support-3.7.1/lib /Users/peter.souter/.rbenv/versions/2.7.3/lib/ruby/gems/2.7.0/gems/rspec-core-3.7.1/exe/rspec --pattern spec/\*\*\{,/\*/\*\*\}/\*_spec.rb

smoke checking Vault docker setup
  Docker
    docker should be running
  checking Vault container running and accessable
    when starting a Vault container
      should not be nil
      should wait for match /Vault server started! Log data will stream in below/ in console output []
    accessing Vault with ruby API gem
      responds to the Vault gem

Finished in 4.23 seconds (files took 0.25176 seconds to load)
4 examples, 0 failures
```

Heavily based on https://github.com/cptactionhank/docker-atlassian-bamboo