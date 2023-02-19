class FileOperator

	attr :debug;

	def initialize(d)
		@debug = d;
	end

	# if e is nil, then return contents from start line till the EOF
	def contents(fn,s,e=nil)
		s=s.to_i;e=e.to_i;
		fh = File.open(fn,'r');
		cnts = [];
		all = fh.readlines();
		len = all.length;
		e=len if e==nil;
		for i in (s..e)
			@debug.print("process line:#{i}");
			cnts << all[i-1].chomp;
		end
		return cnts;
	end
end
