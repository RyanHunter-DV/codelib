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
		o.parse;
	end

	def run ##{{{
	end ##}}}

end