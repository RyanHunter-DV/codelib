class ShellCmd
	attr_accessor :editor;
	attr_accessor :debug;
	def initialize(d) ##{{{
		@editor = ENV['EDITOR'] if ENV.has_key?('EDITOR');
		@editor = 'vim' if @editor==nil or @editor=='';
		@debug  = d;
		@debug.print("using editor: #{@editor}");
	end ##}}}

	# special for codelib tool, create a tmp file, put descript head, and collect user entered
	# contents
	def getUserDescription ##{{{
		tmpf = "./.tmpf_cbrb_#{Process.pid}";
		fh = File.open(tmpf,'w');
		fh.write("please enter your codeblock description below:");
		fh.close;
		cmd = "#{@editor} #{tmpf}";
		@debug.print("call cmd: #{cmd}");
		sig = system(cmd);
		@debug.print("get #{@editor} return sig: #{sig}");
		if sig!=true
			system("rm -rf #{tmpf}");
			raise RunException.new("description create failed",sig);
		end
		# read description
		fh = File.open(tmpf,'r');
		desc = fh.readlines();
		fh.close;
		system("rm -rf #{tmpf}");
		desc.delete_at(0);
		desc.each do |line|
			line.chomp!;
		end
		return desc;
	end ##}}}

	# delete a specified file
	def remove(p,f) ##{{{
		full = File.join(p,f);
		File.delete(full) if File.exists?(full);
		return;
	end ##}}}
end
