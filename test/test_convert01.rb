require 'minitest/autorun'
require 'minitest/spec'

# load the main file
require_relative '../app/convert01'

describe 'convert_01' do
  
  describe 'temp' do
    before do
      @c = Convert_01.new
    end
    
    it "can be created with no arguments" do
      Array.new.must_be_instance_of Array
    end
  
    it "can be created with a specific size" do
      Array.new(10).size.must_equal 10
    end
  end
  
  describe 'config' do
    before do
      @c = Convert_01.new
    end
    
    it 'not nil' do
      @c.wont_be_nil
    end
    
    it 'have a string above zero length' do
      @c.dir_src.length.must_be :>, 0
      @c.dir_temp.length.must_be :>, 0
      @c.dir_dest.length.must_be :>, 0
      @c.opt_rsync.length.must_be :>, 0
      @c.opt_lame.length.must_be :>, 0
      @c.opt_mp3splt.length.must_be :>, 0
    end
  end
  
  describe 'str command helpers' do
    before do
      @c = Convert_01.new
    end
    
    describe 'rsync' do
      it 'test 1' do
        opt = "-v -r -a -h"
        src = "foo/"
        dest = "bar/"
        result = @c.rsync_str(opt, src, dest)
        
        result.wont_be_nil
        result.length.must_be :>, 0
        result.must_equal 'rsync -v -r -a -h foo/ bar/'
      end
    end
    
    describe 'mp3splt' do
      it 'test 1' do
        opt = "-f -t 10.00"
        dest = "bar.mp3"
        result = @c.mp3splt_str(opt, dest)
        
        result.wont_be_nil
        result.length.must_be :>, 0
        result.must_equal 'mp3splt -f -t 10.00 bar.mp3'
      end
    end
    
    describe 'rm' do
      it 'test 1' do
        opt = "-rf"
        dest = "bar.mp3"
        result = @c.rm_str(opt, dest)
        
        result.wont_be_nil
        result.length.must_be :>, 0
        result.must_equal 'rm -rf bar.mp3'
      end
    end
    
    describe 'lame' do
      it 'test 1' do
        opt = "-acodec libmp3lame -ab 320k"
        src = "foo.m4a"
        dest = "bar.mp3"
        result = @c.lame_str(opt, src, dest)
        
        result.wont_be_nil
        result.length.must_be :>, 0
        result.must_equal 'ffmpeg -i foo.m4a -acodec libmp3lame -ab 320k bar.mp3'
      end
    end
  end
  
  describe 'str misc helpers' do
    before do
      @c = Convert_01.new
    end
    
    describe 'is_m4a' do
      it 'test true' do
        file_name = 'foo.m4a'
        result = @c.is_m4a? file_name
        result.must_equal true  
      end
      
      it 'test false' do
        file_name = 'foo.mp3'
        result = @c.is_m4a? file_name
        result.must_equal false  
      end
    end
    
    describe 'ext_to_mp3' do
      it 'test diff' do
        file_name = 'foo.m4a'
        result = @c.ext_to_mp3 file_name
        result.must_equal 'foo.mp3'  
      end
      
      it 'test same' do
        file_name = 'foo.mp3'
        result = @c.ext_to_mp3 file_name
        result.must_equal 'foo.mp3'  
      end
    end
    
    describe 'escaped_file_name' do
      it 'test 1' do
        file_name = 'foobarmedia.m4a'
        result = @c.escaped_file_name file_name
        result.must_equal 'foobarmedia.m4a'  
      end
      
      it '2 spaces' do
        file_name = 'foo sss.mp3'
        result = @c.escaped_file_name file_name
        result.must_equal 'foo\ sss.mp3'  
      end
      
      it '3 hypens and space' do
        file_name = "foo's awesome song.mp3"
        result = @c.escaped_file_name file_name
        result.must_equal "foo\\\'s\\\ awesome\\\ song.mp3"
      end
      
      it '& test' do
        file_name = "foos&  song.mp3"
        result = @c.escaped_file_name file_name
        result.must_equal "foos\\\&\\\ \\\ song.mp3"
      end
    end
  end
  
  describe 'file helpers' do
    describe 'remove spaces' do
      before do
        @c = Convert_01.new
      end
      
      it 'test 1' do
        list = ['.', '..']
        final = []
        result = @c.remove_hidden_files list
        result.must_equal final
      end
      
      it 'test 2' do
        list = ['aaa.mp3', 'zzz.mp3']
        final = ['aaa.mp3', 'zzz.mp3']
        result = @c.remove_hidden_files list
        result.must_equal final
      end
      
      it 'test 3' do
        list = ['aaa.mp3', '..', '.foo.mp3', 'bar.mp3']
        final = ['aaa.mp3', 'bar.mp3']
        result = @c.remove_hidden_files list
        result.must_equal final
      end
    end
  end
  
end