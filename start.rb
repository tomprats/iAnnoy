require_relative 'spam'

spam = Spam.new

if spam.time?
  spam.execute!
end
