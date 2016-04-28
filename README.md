# Calling Shell Commands from Ruby

...while collecting stdout, stderr, and exit status in Ruby for use
elsewhere such as logging to a database, and concurrently logging
in real-time to separate logs (one log for stdout and one log for
stderr).

## Run Script

To view output, run ruby script which calls err_test.sh:

```
ruby ruby_err_test.rb
```

Ideally, we'd like to see stdout as Ruby output, stderr as Ruby error,
and exit status as Ruby result, while also seeing stdout in the
err_test.log and stderr in the err_test.err.log.
