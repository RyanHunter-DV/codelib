require 'database.rb'
require 'shellcmd.rb'
require 'fileOperator.rb'
module CommandPanel

	attr_accessor :options;
	attr_accessor :db;
	attr_accessor :sh;

	attr :debug;
	attr :needs;
	attr :processes;

	def loadCommands
		cmdpath = 'cmds';
		fs = Dir.children;
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
		@needs=[];@processes=[];
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

	def self.need(&block) ##{{{
		p -> {
			v="@#{cmds.last}needs".to_sym;
			self.define_instance_variable(v,{});
			block.call;
		};
		@debug.print("get cmd for need: #{@cmd.last}");
		@needs[@cmds.last] = p;
	end ##}}}

	def self.process(&block) ##{{{
		@debug.print("get cmd for process: #{@cmd.last}");
		@processes[@cmds.last] = &block;
	end ##}}}

	def self.createCommand(n,&block) ##{{{
		self.instance_eval &block;
		prem = "pre#{n.capitalize}";
		self.define_singleton_method prem do
			@debug.print("calling method #{prem}");
			self.instance_eval @needs[n];
		end
		self.define_singleton_method n do
			@debug.print("calling method #{n}");
			self.instance_eval @processes[n];
		end
	end ##}}}
end


def command(n,&block)
	CommandPanel.createCommand(n,&block);
end