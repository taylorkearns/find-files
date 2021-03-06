require 'FileUtils'
include FileTest

def write_file_path(file, paths_file_location, file_path)
  f = File.open(paths_file_location, "a")
  f.puts(file_path + "\n")
end

def copy_file(file, file_path, copy_dir)
  if !File.exists?(copy_dir + "/" + file)
    FileUtils.cp(file_path, copy_dir)
  end
end

def search_folders(file_extension, paths_file_location, copy_dir, matching_files_folder, copy_files)
  # get each file in this directory that has the required extension   
  matching_files = Dir["*" + file_extension + "*"]
  matching_files.reject!{ |file| File.directory?(file) }
  matching_files.each do |file|
    file_path = File.absolute_path(file)
    write_file_path(file, paths_file_location, file_path)
    if copy_files
      copy_file(file, file_path, copy_dir)
    end
  end
  # get each directory inside the current directory, excluding the copy directory
  folders = Dir.entries(Dir.getwd).select{ |i| File.directory?(i) and i.index(/^\./) === nil and i.to_s != matching_files_folder }
  # for each directory
  if folders.any?
    folders.each do |folder|
      # open that folder and run search function on it
      Dir.chdir(File.absolute_path(folder))
        search_folders(file_extension, paths_file_location, copy_dir, matching_files_folder, copy_files)
      Dir.chdir("..")
    end
  end
end

def init # *something's up with using initialize
  puts "What text should be included in the file name?"
  STDOUT.flush
  file_extension = gets.chomp
  puts "Do you want to copy the matched files? Enter 'y' or 'n'."
  STDOUT.flush
  copy_files_answer = gets.chomp.downcase
  copy_files = true if (copy_files_answer === 'y' || copy_files_answer === 'yes')
  matching_files_folder = "matching-files"
  search_dir = Dir.getwd
  Dir.chdir(search_dir)
  # create a new directory inside the search directory
  if !File.exists?(matching_files_folder)
    Dir.mkdir(matching_files_folder)
  end
  # create a text file in the new directory (paths file)
  Dir.chdir("./" + matching_files_folder)
  paths_file = File.new("./file-paths.txt", "w+")
  paths_file_location = File.absolute_path(paths_file)
  if !File.exists?("files") && copy_files === true
    Dir.mkdir("files")
  end
  if File.exists?("files") && copy_files === true
    Dir.chdir("./files") 
    copy_dir = Dir.getwd
    # get back into search directory
  else
    copy_dir = nil
  end
  Dir.chdir(search_dir)
  search_folders(file_extension, paths_file_location, copy_dir, matching_files_folder, copy_files)
end
init()