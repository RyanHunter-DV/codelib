**description**
use options according to OptionParser
**codeid**
Options
**code**
require 'optparse.rb'
class Options
	attr_accessor :options;

	attr :debug;
	def initialize(d) ##{{{
		@debug = d;
		initOptions;
		opt = OptionParser.new() do |o|
			o.on('-e','--entry=ENTRYFILE','specify the entry file of user source') do |v|
				@options[:entry] = v;
			end
			o.on('-r','--root=ROOTPATH','specify the root path of files to be built') do |v|
				@options[:path] = v;
			end
		end.parse!
		## check options
		checkUserOptions;
	end ##}}}

	def checkUserOptions ##{{{
		e = @options[:entry];
		raise RunException.new("invalid entry specified(#{e})",3) unless e != '' and File.exists?(e);
		p = @options[:path];
		raise RunException.new("invalid path specified(#{p})",3) unless p != '';
		return;
	end ##}}}
	def initOptions ##{{{
		@options={};
		@options[:entry] = '';
		@options[:path] = '';
	end ##}}}
end
