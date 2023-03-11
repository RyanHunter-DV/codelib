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
	attr :currentCmd;

	def self.loadCommands
		cmdpath = 'cmds';
		r = File.dirname(File.absolute_path(__FILE__));
		fs = Dir.children(File.join(r,cmdpath));
		fs.each do |f|
			@debug.print("loading command #{f}");
			require File.join(cmdpath,f);
		end
	end

	def self.setup(o,d) ##{{{
		@options = o;
		@debug   = d;
		@currentCmd;
		@db = DataBase.new(@debug);
		@sh = ShellCmd.new(@debug);
		@needs={};@processes={};
		@db.load;
		loadCommands; 
	end ##}}}


	def self.readUserOption(count=1) ##{{{
		return ARGV.shift if count==1;
		opts = [];
		count.times do
			opts << ARGV.shift;
		end
		return opts;
	end ##}}}

	def self.need(&block) ##{{{
		p = lambda { |s|
			@debug.print("processing need for cmd: #{@currentCmd}");
			v="@#{@currentCmd}needs".to_sym;
			self.instance_variable_set(v,{});
			block.call;
		};
		@debug.print("get cmd for need: #{@currentCmd}");
		@needs[@currentCmd] = p;
	end ##}}}

	def self.process(&block) ##{{{
		@debug.print("get cmd for process: #{@currentCmd}");
		@processes[@currentCmd] = block;
	end ##}}}

	def self.createCommand(n,&block) ##{{{
		@currentCmd= n;
		self.instance_eval &block;
		prem = "pre#{n.capitalize}";
		self.define_singleton_method prem do
			@debug.print("calling method #{prem}, n: #{n}, instance: #{@needs[n]}");
			p = @needs[n];
			@currentCmd=n;
			self.instance_eval &p;
		end
		self.define_singleton_method n do
			@debug.print("calling method #{n}");
			self.instance_eval &@processes[n];
		end
	end ##}}}
end


def command(n,&block)
	CommandPanel.createCommand(n,&block);
end
