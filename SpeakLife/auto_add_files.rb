#!/usr/bin/env ruby

require 'xcodeproj'
require 'find'

def add_untracked_swift_files
  project_path = 'SpeakLife.xcodeproj'
  
  # Get list of untracked Swift files from git
  untracked_files = `git ls-files --others --exclude-standard`.split("\n")
  swift_files = untracked_files.select { |f| f.end_with?('.swift') && f.start_with?('SpeakLife/') }
  
  return if swift_files.empty?
  
  puts "Found #{swift_files.length} untracked Swift files:"
  swift_files.each { |f| puts "  - #{f}" }
  
  # Open the project
  project = Xcodeproj::Project.open(project_path)
  
  # Find the main target
  target = project.targets.find { |t| t.name == 'SpeakLife' }
  
  swift_files.each do |file_path|
    begin
      # Add the file to the project
      file_ref = project.main_group.new_reference(file_path)
      
      # Add to the target
      target.add_file_references([file_ref])
      
      puts "✅ Added #{file_path} to Xcode project"
    rescue => e
      puts "❌ Failed to add #{file_path}: #{e.message}"
    end
  end
  
  # Save the project
  project.save
  puts "\nProject saved successfully!"
end

# Run the function
add_untracked_swift_files