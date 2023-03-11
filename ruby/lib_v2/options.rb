require 'optparse.rb';
require 'commandPanel.rb'
require 'exceptions.rb'

class Options

	attr_accessor :options;

	def initialize
		@options = {};
	end
	def parse ##{{{
		getCommandUserOptions;
		opt = OptionParser.new() do |o|
			o.on('-f','--FILE=NAME,START,END','specify file information') do |v|
				getFileInfoFromUserParam(v);
			end
		end.parse!
	end ##}}}

	def getCommandUserOptions ##{{{
		cmd = ARGV.shift;
		raise RunException.new("no command specified",3) unless cmd;
		message = "pre#{cmd.capitalize}".to_sym;
		CommandPanel.send(message);
		@options[:cmd] = cmd.to_sym;
	end ##}}}

	def getFileInfoFromUserParam(src) ##{{{
		@options[:file]='';@options[:start]=1;@options[:end]=-1;
		splitted = src.split(',');
		@options[:file] = splitted[0];
		@options[:start]= splitted[1] if splitted.length>1;
		@options[:end]  = splitted[2] if splitted.length>2;
		return;
	end ##}}}
end
