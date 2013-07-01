# copies stuff from itunes to a usb thumb drive
# 
# here is what it does.
# 1. convert m4a files to mp3.
# 2. split all mp3 files to 10 minute chunks
# 3. copies the stuff over to a thumb drive.
#
# the utility uses a few apps so you will need these utilities.
#

require 'yaml'

class Convert_01

  # accessors
  # make them visible to the public.
  # just for testing.
  attr_accessor :dir_src, :dir_temp, :dir_dest, :opt_rsync, :opt_lame, :opt_mp3splt

  def initialize
    # load the config file.
    self.load_config_file
  end
  
  def load_config_file
    file_name = File.join( File.dirname( File.expand_path(__FILE__) ), 'config.yml')
    config = YAML::load( File.open(file_name) )
    
    # settings
    @dir_src = config['dir_src']
    @dir_temp = config['dir_temp']
    @dir_dest = config['dir_dest']
    @opt_rsync = config['opt_rsync']
    @opt_lame = config['opt_lame']
    @opt_mp3splt = config['opt_mp3splt']
    
    # return config file
    config
  end

	# runs all of the necessary files
	# to convert itunes to something that you can use in the car.
	# here is what it does.
	# 1. copies itunes to a temputsdirectory.
	# 2. figures out what directory has m4a files and converts it.
	# 3. copies the files to a usb thumbdrive.
	def run
		self.rsync_to_temp
		self.convert_to_mp3
		self.rsync_to_usb
		self.delete_temp_dir
	end
	
	# rsync the itunes directory to a temputsdirectory.
	# want to have a place to lame encoding.
	def rsync_to_temp
		puts "\n=> copying to temp dir.\n"
		system self.rsync_str(@opt_rsync, @dir_src, @dir_temp)
	end
	
	# rsync the itunes directory to a temputsdirectory.
	# want to have a place to lame encoding.
	def rsync_to_usb
		puts "\n=> copying to usb.\n"
		system self.rsync_str(@opt_rsync, @dir_temp, @dir_dest)
	end
	
	# clean up. delete the temp dir.
	def delete_temp_dir
		system self.rm_str(" -rf ", @dir_temp)
	end
	
	# fetches the src directory.
	# either copies or converts files to lame.
	def convert_to_mp3
		puts "\n=> look for m4a files and convert it to mp3\n"
		
		# grab directory names.
		dir_names = Dir.entries @dir_temp
		# remove .prefixes
		dir_names = self.remove_hidden_files dir_names
		
		# go thru each sub directories.
		dir_names.each do |current_dir|
			puts "\n=> at " + @dir_temp + current_dir + "\n"
			
			# grabs the files in the directory
			current_files = Dir.entries(@dir_temp + "/" + current_dir)
			
			# remove the . prefixes.
			current_files = self.remove_hidden_files current_files
			
			# cycle thru the files in each directory.
			current_files.each do |current_file|
				# file names
				src_file = ""
				dest_file = ""
			
				# checks if it has a m4a extension
				if self.is_m4a? current_file		
					puts "\n=> encoding " + "[" +current_dir + "][" + current_file + "]"
					
					# creating src and dest files.
					src_file =  @dir_temp + current_dir + '/' + current_file
					dest_file =  @dir_temp + current_dir + '/' + self.ext_to_mp3(current_file)
					
					#src_file = "'" + src_file + "'" 
					#dest_file = "'" + dest_file + "'" 
					
					# escape the names.
					src_file = self.escaped_file_name(src_file)
					dest_file = self.escaped_file_name(dest_file)
					
					puts "=> src " + src_file 
					puts "=> dest " + dest_file
					
					# lame encoding.
					system self.lame_str(@opt_lame, src_file, dest_file)
				elsif self.is_mp3? current_file
				  dest_file = @dir_temp + current_dir + '/' + current_file
					puts ">>> " + dest_file
					dest_file = self.escaped_file_name(dest_file)
					puts ">>>> " + dest_file
					dest_file
				end
				
				# split the mp3...
				system self.mp3splt_str(@opt_mp3splt, dest_file)
				
				# delete the source file.
				# only want the split files.
				system self.rm_str("", dest_file)
				if (src_file != "")
					system self.rm_str("", src_file)
				end
			end
		end
	end
	
	# STRING METHODS.
	############################################################################
	
	# returns a string that you can run system on for rsync.
	def rsync_str(options, src, dest)
		arg = "rsync " + options + " " + src + " " + dest
		# puts "=> rsync " + arg
		# system arg
	end
	
	# returns a string that you can run system on for lame
	# probably need to fix the options.
	def lame_str(options, src, dest)
		arg = "ffmpeg -i " + src + " " + options + " " + dest
		# puts "=> lame " + arg
		# system arg
	end
	
	# mp3splt
	def mp3splt_str(options, src)
		arg = "mp3splt " + options + " " + src
		# puts "=> mp3splt " + arg
		# system arg
	end
	
	# returns a string that you can run system on for rm.
	def rm_str(options, src)
		arg = "rm " + options + " " + src
		# puts arg
		# system arg
	end
	
	# a regex that check if there is a m4a prefix.
	def is_m4a?(filename)
		/.+[.]m4a$/ =~ filename ? true : false
	end
	
	# a regex that check if there is a m4a prefix.
  def is_mp3?(filename)
    /.+[.]mp3$/ =~ filename ? true : false
  end
	
	# rename ext to mp3
	def ext_to_mp3(filename)
		filename_without_ext = filename.gsub(/[.]\w+$/, "")
		filename_without_ext + ".mp3"
	end
	
	# escapes the path with the correct file names.
	# unix does not like spaces. escapes it.
	def escaped_file_name(filename)
		puts "\n=> init " + filename 
		result = filename.gsub(" ", "\\ ")
		
		puts "\n=> init2 " + result
		result2 = result.gsub("\&", "\\\\\&")
    
    puts "\n=> init3 " + result2
		result3 = result2.gsub("\'", "\\\\\'")
		
		puts "\n=> init4 " + result3
		result3
	end
	
	# FILE HELPERS
	############################################################################
	
	# remove all hidden files.
  # given an array of files,
  # remove all ones that prefix by a dot.
  # stuff like ., .. and .someFunc
  def remove_hidden_files(list_of_files)
    results = []
    
    list_of_files.each do |file|
      # skip anything with a dot.
      if /^[.]+.*/ =~ file
        next
      else
        results.push file
      end
    end
    
    results
  end
	
end
