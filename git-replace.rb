#!/usr/bin/env ruby

require 'shellwords'

HELP_MESSAGE = "Very stupid refactoring.\n" \
               "It greedly replaces all occurrencies of a string with a new one.\n" \
               "WARNING:\n" \
               "be careful, your args will be used for bash commands.\n\n" \
               "USAGE: `git-replace.rb \"<OLD>\" \"<NEW>\"".freeze

def ask_for_permission(msg)
  print "#{msg} (y/n) "

  loop do
    answer = $stdin.gets.chomp.downcase
    return 'y' == answer[0] if %w(y n yes no).include?(answer)
    print 'Error! Enter y(es) or n(o): '
  end
end

abort(HELP_MESSAGE) unless ARGV.size == 2

OLD = ARGV[0]
NEW = ARGV[1]

git_grep_command = "git grep #{Shellwords.escape OLD}"

puts "Command: #{git_grep_command}"
grep_result = `#{git_grep_command}`

puts nil, grep_result, nil
exit unless ask_for_permission('Is it ok?')

file_list = grep_result
            .lines
            .map { |line| Shellwords.escape(line.split(':')[0]) }
            .uniq
puts
file_list.each do |file|
  print "writing #{file}... "
  old_content = File.read(file)
  new_content = old_content.gsub(OLD, NEW)
  File.write(file, new_content)
  puts 'ok'
end

puts 'DONE'
