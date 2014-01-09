require_relative 'spam'
require_relative 'arguments'

arguments = Arguments.new

help  = arguments.get_help
debug = arguments.get_debug
ugly  = arguments.get_ugly
name  = arguments.get_name
color = arguments.get_color
file  = arguments.get_file

help = true unless arguments.valid_name(name)
help = true unless arguments.valid_color(color)
help = true unless arguments.valid_file(file)

if !help
  spam = Spam.new(
    debug: debug,
    pretty: !ugly,
    name: name,
    color: color,
    file: file
  )

  if spam.time?
    spam.execute!
  else
    puts "It is not time yet"
  end
else
  arguments.show
end
