require 'rake'
require 'erb'

excludes = %w[Rakefile README.rdoc LICENSE bin autojump man git-tools sshuttle gitflow todo.txt-cli libraries xssh git-archive-all git-blameall git-store cheat pastebinit]

desc "install the dot files into user's home directory"
task :install do
  replace_all = false
  update_submodules()
  Dir['*'].each do |file|
    next if excludes.include? file
    
    new_filename = ".#{file.sub('.erb', '')}"
    if File.exist?(File.join(ENV['HOME'], "#{new_filename}"))
      if File.identical? file, File.join(ENV['HOME'], "#{new_filename}")
        puts "identical ~/#{new_filename}"
      elsif replace_all
        replace_file(file, new_filename)
      else
        print "overwrite ~/#{new_filename} ? [ynaq] "
        case $stdin.gets.chomp
        when 'a'
          replace_all = true
          replace_file(file, new_filename)
        when 'y'
          replace_file(file, new_filename)
        when 'q'
          exit
        else
          puts "skipping ~/#{new_filename}"
        end
      end
    else
      link_file(file)
    end
  end
end

desc "update submodules"
task :update do
    update_submodules()
end

desc "remove backup files"
task :clean do
  Dir['*'].each do |file|
    next if excludes.include? file
    backup_filename = ".#{file.sub('.erb', '')}.old"
    if File.exist?(File.join(ENV['HOME'], "#{backup_filename}"))
      puts "Removing ~/#{backup_filename}"
      system %Q{rm -f "$HOME/#{backup_filename}"}
    end
  end
end

def replace_file(file, new_filename)
  if not File.symlink?(File.join(ENV['HOME'], "#{new_filename}"))
    backup = "#{new_filename}.old"
    puts "backuping ~/#{new_filename} to ~/#{backup}"
    system %Q{mv -f "$HOME/#{new_filename}" "$HOME/#{backup}"}
  else
    system %Q{rm -f "$HOME/#{new_filename}"}
  end
  link_file(file)
end

def link_file(file)
  if file =~ /.erb$/
    puts "generating ~/.#{file.sub('.erb', '')}"
    File.open(File.join(ENV['HOME'], ".#{file.sub('.erb', '')}"), 'w') do |new_file|
      new_file.write ERB.new(File.read(file)).result(binding)
    end
  else
    puts "linking ~/.#{file}"
    system %Q{ln -s "$PWD/#{file}" "$HOME/.#{file}"}
  end
end

def update_submodules()
    system %Q{git submodule sync --recursive && git submodule update --init --recursive}
end
