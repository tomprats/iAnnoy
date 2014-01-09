require_relative 'spam'

def get_name
  name = ARGV.index("--name") || ARGV.index("-n")

  if name
    if name < ARGV.length - 1
      name = ARGV[name + 1]
    else
      name = false
    end
  else
    name = "GitCheck"
  end

  name
end

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

def valid_name(name)
  return true if name
  puts ""
  puts "Name incorrectly specified"
  puts ""
  false
end

def valid_color(color)
  return true if ["yellow", "red", "green", "purple", "gray", "random"].include? color
  puts ""
  puts "Color incorrectly specified"
  puts ""
  false
end

help  = ARGV.include?("--help")  || ARGV.include?("-h")
debug = ARGV.include?("--debug") || ARGV.include?("-d")
ugly  = ARGV.include?("--ugly")  || ARGV.include?("-u")

name = get_name
color = get_color
help = true unless valid_name(name)
help = true unless valid_color(color)

if !help
  spam = Spam.new(debug: debug, pretty: !ugly, name: name, color: color)

  if spam.time?
    spam.execute!
  else
    puts "It is not time yet"
  end
else
  puts ""
  puts "Command line options include:"
  puts "  Shorthand"
  puts "    -h            => To see this listing again"
  puts "    -d            => To turn off hipchat output"
  puts "    -u            => To output in a more verbose format"
  puts "    -n NAME       => To choose name hipchat uses (defaults to GitCheck)"
  puts "    -c COLOR      => To specify hipchat output color (defaults to random)"
  puts ""
  puts "  Full"
  puts "    --help        => To see this listing again"
  puts "    --debug       => To turn off hipchat output"
  puts "    --ugly        => To output in a more verbose format"
  puts "    --name NAME   => To choose name hipchat uses (defaults to GitCheck)"
  puts "    --color COLOR => To specify hipchat output color (defaults to random)"
  puts ""
end
