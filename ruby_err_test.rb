require 'open3'

class RubyErrTest
  def self.run_success_and_error_for(with)
    ret = self.new
    ret.clear_logs
    ret.run_err(with: with)
    puts "- "*25
    ret.clear_logs
    ret.run_err(input: "fail", with: with)
    puts "="*50
  end

  def run_err(input:"success", with:"bash")
    puts "Ruby running input \"#{input}\" with #{with}"

    # Desired output would be:
      # stdout to Ruby: yes
      # stderr to Ruby: yes
      # result to Ruby: yes
      # stdout to logs: yes
      # stderr to logs: yes
    case with
    when "bash"
      # stdout to Ruby: yes
      # stderr to Ruby: no
      # result to Ruby: yes
      # stdout to logs: no
      # stderr to logs: no
      output = bash("bash #{script} #{input}")
      result = $?
      error = nil
    when "sh"
      # stdout to Ruby: yes
      # stderr to Ruby: no
      # result to Ruby: yes
      # stdout to logs: no
      # stderr to logs: no
      output = %x(bash #{script} #{input})
      result = $?
      error = nil
    when "sh_with_redirected_stderr"
      # stdout to Ruby: yes
      # stderr to Ruby: yes/no (yes but combined with stdout)
      # result to Ruby: yes
      # stdout to logs: no
      # stderr to logs: no
      output = %x(bash #{script} #{input} 2>&1)
      result = $?
      error = nil
    when "sh_with_log"
      # => syntax error due to bash process substitution being run with `sh`
      output = %x(bash #{script} #{input} > >(tee -a #{output_log}) 2> >(tee -a #{error_log} >&2))
      result = $?
      error = nil
    when "bash_with_log"
      # stdout to Ruby: no
      # stderr to Ruby: no
      # result to Ruby: yes
      # stdout to logs: yes
      # stderr to logs: yes
      output = bash( "bash #{script} #{input} > >(tee -a #{output_log}) 2> >(tee -a #{error_log} >&2)" )
      result = $?
      error = nil
    when "capture3"
      # stdout to Ruby: yes
      # stderr to Ruby: yes
      # result to Ruby: yes
      # stdout to logs: no
      # stderr to logs: no
      output, error, result = Open3.capture3("bash", script, input)
    when "capture3_with_log_as_one_command"
      # => syntax error due to bash process substitution being run with `sh`
      output, error, result = Open3.capture3("bash #{script} #{input} > >(tee -a #{output_log}) 2> >(tee -a #{error_log} >&2)")
    when "capture3_with_log_as_arguments"
      # stdout to Ruby: yes
      # stderr to Ruby: yes
      # result to Ruby: yes
      # stdout to logs: no
      # stderr to logs: no
      output, error, result = Open3.capture3("bash", script, input, "> >(tee -a #{output_log}) 2> >(tee -a #{error_log} >&2)")
    end
    puts "Ruby result: #{result.inspect}"
    puts "Ruby output: #{output.inspect}"
    puts "Ruby error: #{error.inspect}"
    puts "Output log: #{IO.read(output_log).inspect}"
    puts "Error log: #{IO.read(error_log).inspect}"
  end

  def bash(command)
    system("bash", "-c", command)
  end

  def directory
    File.expand_path(File.dirname(__FILE__))
  end

  def output_log
    File.join(directory, "err_test.log")
  end

  def script
    File.join(directory, "err_test.sh")
  end

  def error_log
    File.join(directory, "err_test.err.log")
  end

  def clear_logs
    [output_log, error_log].each { |f| File.truncate(f, 0) }
  end
end

RubyErrTest.run_success_and_error_for("bash")
RubyErrTest.run_success_and_error_for("sh")
RubyErrTest.run_success_and_error_for("sh_with_redirected_stderr")
RubyErrTest.run_success_and_error_for("sh_with_log")
RubyErrTest.run_success_and_error_for("bash_with_log")
RubyErrTest.run_success_and_error_for("capture3")
RubyErrTest.run_success_and_error_for("capture3_with_log_as_one_command")
RubyErrTest.run_success_and_error_for("capture3_with_log_as_arguments")
