# sync itunes.
class SyncItunes
	# settings
	@@dir_src = '/Users/hubertwong/Music/iTunes/iTunes\\ Media/Podcasts/'
	#@@dir_src = '/Users/hubertwong/Music/iTunes/'
	@@dir_dest = '/Volumes/SANDISKUSB/PODCASTS/'
	@@options = '-v -r -a -h'
	
	def run
		p self.rsync_str
		exec 'rsync ' + self.rsync_str
	end
	
	def rsync_str
		'rsync ' + @@options + ' ' + @@dir_src + ' ' + @@dir_dest
	end
	
end

# runner
m = SyncItunes.new
m.run
