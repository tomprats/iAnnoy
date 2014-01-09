class Arguments
  def show
    puts ""
    puts "Command line options include:"
    puts "  Shorthand"
    puts "    -h            => To see this listing again"
    puts "    -d            => To turn off hipchat output"
    puts "    -u            => To output in a more verbose format"
    puts "    -n NAME       => To choose name hipchat uses (defaults to GitCheck)"
    puts "    -c COLOR      => To specify hipchat output color (defaults to random)"
    puts "    -f FILE       => To specify organization json file (defaults to organization.json)"
    puts ""
    puts "  Full"
    puts "    --help        => To see this listing again"
    puts "    --debug       => To turn off hipchat output"
    puts "    --ugly        => To output in a more verbose format"
    puts "    --name NAME   => To choose name hipchat uses (defaults to GitCheck)"
    puts "    --color COLOR => To specify hipchat output color (defaults to random)"
    puts "    --file FILE   => To specify organization json file (defaults to organization.json)"
    puts ""
  end

  def get_help
    ARGV.include?("--help")  || ARGV.include?("-h")
  end

  def get_debug
    ARGV.include?("--debug") || ARGV.include?("-d")
  end

  def get_ugly
    ARGV.include?("--ugly")  || ARGV.include?("-u")
  end

  def get_name
    index = ARGV.index("--name") || ARGV.index("-n")
    words = []

    if index
      while (index + 1 < ARGV.length) && !ARGV[index + 1].start_with?("-")
        words.push(ARGV[index + 1])
        index += 1
      end
    end

    if words.empty? || !index
      false
    else
      words.join(" ")
    end
  end

  def get_color
    index = ARGV.index("--color") || ARGV.index("-c")

    if index
      if(index + 1 < ARGV.length)
        color = ARGV[index + 1]
      else
        color = "invalid"
      end
    else
      color = "random"
    end

    color
  end

  def get_file
    index = ARGV.index("--file") || ARGV.index("-f")

    if index
      if(index + 1 < ARGV.length)
        file = ARGV[index + 1]
      else
        file = false
      end
    else
      file = "organization.json"
    end

    file
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

  def valid_file(file)
    return true if file
    puts ""
    puts "File incorrectly specified"
    puts ""
    false
  end
end
