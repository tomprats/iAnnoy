require_relative 'spam'

def get_color
  color = ARGV.index("--color")    || ARGV.index("-c")

  if color
    if color < ARGV.length - 1
      color = ARGV[color + 1]
    else
      color = "invalid"
    end
  else
    color = "random"
  end

  color
end

def valid_color(color)
  if ["yellow", "red", "green", "purple", "gray", "random"].include? color
    true
  else
    puts "Color incorrectly specified"
    puts ""
    false
  end
end

help  = ARGV.include?("--help")  || ARGV.include?("-h")
debug = ARGV.include?("--debug") || ARGV.include?("-d")
ugly  = ARGV.include?("--ugly")  || ARGV.include?("-u")
color = get_color
help = true unless valid_color(color)

if !help
  spam = Spam.new(debug: debug, pretty: !ugly, color: color)

  if spam.time?
    spam.execute!
  end
else
  puts "Command line options include:"
  puts "  Shorthand"
  puts "    -h            => To see this listing again"
  puts "    -d            => To turn off hipchat output"
  puts "    -u            => To output in a more verbose format"
  puts "    -c COLOR      => To specify hipchat output color (defaults to random)"
  puts ""
  puts "  Full"
  puts "    --help        => To see this listing again"
  puts "    --debug       => To turn off hipchat output"
  puts "    --ugly        => To output in a more verbose format"
  puts "    --color COLOR => To specify hipchat output color (defaults to random)"
  puts ""
end
