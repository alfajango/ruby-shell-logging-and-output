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

## Sample Output

To see the resulting output without having to download and run this
project, see [sample_output.txt](sample_output.txt).

## Some of the issues encountered

This method redirects stderr to stdout so that we can capture both
outputs and view the response status code. The problem is, we may have
some script which logs a lot to stdout, stderr, or both such that it's
not immediately obvious what exactly the error was when the result is a
failure:

```
output = %x(bash ./err_test.sh arg 2>&1)
result = $?
```

We could log stdout and stderr to separate files, but now we lose
stderr showing up in the output to log when command does not exit
successfully:

```
output = %x(bash ./err_test.sh arg >>output.log 2>>error.log)
result = $?
```

We could log stdout and stderr to separate files and also combine both
into actual output by redirecting into tee, which will send input to
file and stdout and stdout to other file and stderr, using process
substitution, however this will actually result in a syntax error since
Ruby uses the environment's standard shell (which is `sh` rather than
`bash` on OSX and Ubuntu), which doesn't have process substitution:

```
output = %x(bash ./err_test.sh arg > >(tee -a output.log) 2> >(tee -a error.log >&2)"
result = $?
```

Or redirect stdout and stderr to respective logs, but then only redirect
stderr back to output (without stdout), since in this particular case we
may only be interested in logging errors and don't care about stdout,
however this has the same issue as the previous example... no process
substitution in `sh`:

```
error = %x(bash ./err_test.sh arg >>output.log 2> >(tee -a error.log >&2)"
result = $?
```

We could try one of the previous commands which uses `tee` for splitting
stdout and stderr into both logfiles and back into stdout and stderr,
respectively, by using the `system` call to specify to use bash to run
the command. This makes the process substitution work such that the
stdout and stderr are redirected to their respective logs with `tee`,
however, `system` returns the exit status result instead of stdout, so
we end up losing any stdout or stderr within Ruby:

```
result = system("bash", "-c", "bash ./err_test.sh arg >>output.log 2> >(tee -a error.log >&2)")
```

We could use `Open3.capture3` to capture stdout, stderr, and exit status
result from the command in Ruby, and also specify to use `bash` so that
process substitution with `tee` works. However, because `#capture3`
treats the command arguments as untrusted user input, it ends up
discarding the arguments that specify output redirection, which results
in us successfully getting stdout, stderr, and exit status result in
Ruby, but nothing gets logged:

```
output, error, result = Open3.capture3("bash", "./err_test.sh", arg, "> >(tee -a output.log) 2> >(tee -a error.log >&2)")
```

We could potentially use something more low-level than `#capture3` such
as the `#popen3` method it relies on directly in order to be able to
stream stdout and stderr to their respective logs while capturing them
independently in ruby; however there are then potentially issues with
deadlocks when using `#popen3` in Ruby due to overflowing pipe buffers
when reading from e.g. stdout when stderr is a lot of data being
streamed to it, which would need to be dealt with, leading to more
brittle code which needs more testing in more scenarios for the actual
shell scripts being run.

For reference to these potential issues with `popen3`, see the following
resources:

 * http://ruby-doc.org/stdlib-2.1.0/libdoc/open3/rdoc/Open3.html#method-c-popen3
 * https://bugs.ruby-lang.org/issues/9082
 * http://coldattic.info/shvedsky/pro/blogs/a-foo-walks-into-a-bar/posts/63
 * http://illuminatedcomputing.com/posts/2011/10/piping-in-ruby-with-popen3/
