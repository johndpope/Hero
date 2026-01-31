#!/usr/bin/env ruby
# Script to add LegacyExamples files to the HeroExamples target
# Uses the xcodeproj gem (bundled with CocoaPods)

require 'xcodeproj'

project_path = File.join(__dir__, 'Hero.xcodeproj')
project = Xcodeproj::Project.open(project_path)

# Find the HeroExamples target
target = project.targets.find { |t| t.name == 'HeroExamples' }
unless target
  puts "ERROR: Could not find HeroExamples target"
  exit 1
end

puts "Found target: #{target.name}"

# Find or create the LegacyExamples group in the project
legacy_group = project.main_group['LegacyExamples']
unless legacy_group
  puts "ERROR: Could not find LegacyExamples group in project navigator"
  puts "Available groups: #{project.main_group.children.map(&:display_name).join(', ')}"
  exit 1
end

puts "Found LegacyExamples group"

# Collect all existing source file paths already in the target
existing_sources = target.source_build_phase.files.map { |f| f.file_ref&.real_path&.to_s }.compact
existing_resources = target.resources_build_phase.files.map { |f| f.file_ref&.real_path&.to_s }.compact

puts "\nExisting source files in target: #{existing_sources.count}"
puts "Existing resource files in target: #{existing_resources.count}"

# Recursively find all file references in the LegacyExamples group
def find_files_recursive(group)
  files = []
  group.children.each do |child|
    if child.is_a?(Xcodeproj::Project::Object::PBXGroup)
      files += find_files_recursive(child)
    elsif child.is_a?(Xcodeproj::Project::Object::PBXFileReference)
      files << child
    end
  end
  files
end

all_legacy_files = find_files_recursive(legacy_group)
puts "\nFound #{all_legacy_files.count} file references in LegacyExamples group"

swift_files = all_legacy_files.select { |f| f.path&.end_with?('.swift') }
storyboard_files = all_legacy_files.select { |f| f.path&.end_with?('.storyboard') }

puts "  Swift files: #{swift_files.count}"
puts "  Storyboard files: #{storyboard_files.count}"

# Add Swift files to Compile Sources build phase
added_sources = 0
swift_files.each do |file_ref|
  real_path = file_ref.real_path.to_s
  unless existing_sources.include?(real_path)
    target.source_build_phase.add_file_reference(file_ref)
    puts "  + Added to Compile Sources: #{file_ref.path}"
    added_sources += 1
  else
    puts "  = Already in Compile Sources: #{file_ref.path}"
  end
end

# Add Storyboard files to Copy Bundle Resources build phase
added_resources = 0
storyboard_files.each do |file_ref|
  real_path = file_ref.real_path.to_s
  unless existing_resources.include?(real_path)
    target.resources_build_phase.add_file_reference(file_ref)
    puts "  + Added to Bundle Resources: #{file_ref.path}"
    added_resources += 1
  else
    puts "  = Already in Bundle Resources: #{file_ref.path}"
  end
end

puts "\n--- Summary ---"
puts "Added #{added_sources} Swift files to Compile Sources"
puts "Added #{added_resources} Storyboard files to Bundle Resources"

if added_sources > 0 || added_resources > 0
  project.save
  puts "\nProject saved successfully!"
else
  puts "\nNo changes needed - all files already in target."
end
