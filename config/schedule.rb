every :hour do
  command "/usr/bin/ruby #{File.expand_path("..", File.dirname(__FILE__))}/spam.rb"
end
