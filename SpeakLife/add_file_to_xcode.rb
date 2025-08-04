#!/usr/bin/env ruby

require 'xcodeproj'

if ARGV.length != 1
  puts "Usage: ruby add_file_to_xcode.rb <file_path>"
  exit 1
end

file_path = ARGV[0]
project_path = 'SpeakLife.xcodeproj'

# Open the project
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'SpeakLife' }

# Add the file to the project
file_ref = project.main_group.new_reference(file_path)

# Add to the target
target.add_file_references([file_ref])

# Save the project
project.save

puts "Added #{file_path} to Xcode project"