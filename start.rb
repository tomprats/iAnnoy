require_relative 'spam'

spam = Spam.new(:debug => !ARGV.empty?)

if spam.time?
  spam.execute!
end
