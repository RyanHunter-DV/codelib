class FileOperator

	attr :debug;

	def initialize(d)
		@debug = d;
	end

	# if e is nil, then return contents from start line till the EOF
	def contents(fn,s,e=nil)
		fh = File.open(fn,'r');
		cnts = [];
		all = fh.readlines();
		len = all.length;
		e=len if e==nil;
		s=s.to_i;e=e.to_i;
		@debug.print("positions: file(#{fn}),start(#{s}),end(#{e})");
		for i in (s..e)
			@debug.print("process line:#{i}");
			cnts << all[i-1].chomp;
		end
		return cnts;
	end

	def insert(cnts,fn,s=1) ##{{{
		@debug.print("insert to: #{fn},#{s}");
		puts "insert cnts: #{cnts}";
		fh = File.open(fn,'r');
		origin = fh.readlines();
		fh.close;
		new = [];
		current = 1;
		origin.each do |l|
			@debug.print("looping origin,s:#{s},current:#{current} line:#{l}");
			if s==current
				@debug.print("append cnts:#{cnts} to line:#{current}");
				new.append(*cnts);
			end
			new << l;
			current += 1;
		end
		fh = File.open(fn,'w');
		new.each do |l|
			fh.write(l);
		end
		fh.close;
	end ##}}}
end
