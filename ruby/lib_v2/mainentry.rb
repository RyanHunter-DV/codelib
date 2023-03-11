require 'debugger.rb'
require 'exceptions.rb'
require 'options.rb'
require 'commandPanel.rb'


class MainEntry

	attr_accessor :debug;
	attr_accessor :options;

	def initialize
		@debug = Debugger.new(true);
		o = Options.new();
		@options = o.options;
		CommandPanel.setup(@options,@debug);
	end

	def run ##{{{
		sig = 0;
		begin
			o.parse;
			Commandpanel.send(@options[:cmd]); # process cmd
		rescue RunException => e
			sig = e.process
		end
		return sig;
	end ##}}}

end