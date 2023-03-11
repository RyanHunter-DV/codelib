require 'database.rb'
require 'shellcmd.rb'
require 'fileOperator.rb'
module CommandPanel

	attr_accessor :options;
	attr_accessor :db;
	attr_accessor :sh;

	attr :debug;

	def loadCommands
		cmdpath = 'cmds';
		fs = File.children;
		fs.each do |f|
			@debug.print("loading command #{f}");
			require File.join(cmdpath,f);
		end
	end

	def self.setup(o,d) ##{{{
		@options = o;
		@debug   = d;
		@db = DataBase.new(@debug);
		@sh = ShellCmd.new(@debug);
		loadCommands; 
	end ##}}}


	def readUserOption(count=1) ##{{{
		return ARGV.shift if count==1;
		opts = [];
		count.times do
			opts << ARGV.shift;
		end
		return opts;
	end ##}}}

	def self.createCommand(n,&block) ##{{{
		self.define_singleton_method n.to_sym do
			self.instance_eval &block;
		end
	end ##}}}
end


def command(n,&block)
	CommandPanel.createCommand(n,&block);
end