require 'open3'

class RubyErrTest
  def self.run_success_and_error_for(with)
    ret = self.new
    ret.clear_logs
    ret.run_err(with: with)
    puts "-"*20
    ret.clear_logs
    ret.run_err(input: "fail", with: with)
    puts "-"*50
  end

  def run_err(input:"success", with:"bash")
    puts "Ruby running input \"#{input}\" with #{with}"
    case with
    when "bash"
      output = bash("bash #{script} #{input}")
      result = $?
      error = nil
    when "sh"
      output = %x(bash #{script} #{input})
      result = $?
      error = nil
    when "sh_with_redirected_stderr"
      output = %x(bash #{script} #{input} 2>&1)
      result = $?
      error = nil
    when "sh_with_log"
      output = %x(bash #{script} #{input} > >(tee -a #{output_log}) 2> >(tee -a #{err_log} >&2))
      result = $?
      error = nil
    when "bash_with_log"
      output = bash( "bash #{script} #{input} > >(tee -a #{output_log}) 2> >(tee -a #{err_log} >&2)" )
      result = $?
      error = nil
    when "capture3"
      output, error, result = Open3.capture3("bash", script, input)
    when "capture3_with_log"
      output, error, result = Open3.capture3("bash #{script} #{input} > >(tee -a #{output_log}) 2> >(tee -a #{err_log} >&2)")
    end
    puts "Ruby result: #{result.inspect}"
    puts "Ruby output: #{output.inspect}"
    puts "Ruby error: #{error.inspect}"
    puts "Output log: #{IO.read(output_log).inspect}"
    puts "Err log: #{IO.read(err_log).inspect}"
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

  def err_log
    File.join(directory, "err_test.err.log")
  end

  def clear_logs
    [output_log, err_log].each { |f| File.truncate(f, 0) }
  end
end

RubyErrTest.run_success_and_error_for("bash")
RubyErrTest.run_success_and_error_for("sh")
RubyErrTest.run_success_and_error_for("sh_with_redirected_stderr")
RubyErrTest.run_success_and_error_for("sh_with_log")
RubyErrTest.run_success_and_error_for("bash_with_log")
RubyErrTest.run_success_and_error_for("capture3")
RubyErrTest.run_success_and_error_for("capture3_with_log")
