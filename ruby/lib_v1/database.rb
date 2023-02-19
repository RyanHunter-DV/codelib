class DataBase

	attr :debug;
	attr :dbhome;
	attr :dbfiles;

	def initialize d
		@debug = d;
		@dbfiles=[];
		@dbhome = File.join($toolhome,'db');
		Dir.mkdir(@dbhome) unless Dir.exists?(@dbhome);
	end

	# load files into db
	def load
		@dbfiles = Dir.children(@dbhome);
	end

	def codeid?(id)
		return true if @dbfiles.include?(id+'.md');
		return false;
	end

	# file: <codeid>.md
	# format
	# **description**
	# ...
	# **code**
	# ...
	def store(id,desc,cnts)
		f = File.join(@dbhome,id+'.md');
		fh = File.open(f,'w');
		fh.write("**description**\n");
		desc.each do |l|
			fh.write("#{l}\n");
		end
		fh.write("**code**\n");
		__removeStartIndents__(cnts);
		cnts.each do |l|
			fh.write("#{l}\n");
		end
		fh.close;
	end

	def __removeStartIndents__(src) ##{{{
		start  = true;
		indent = nil;
		m = nil;
		src.each do |s|
			if start==true
				m = /(^\t*)/.match(s);
				if m
					ptrn = "^"+m[1].gsub(/\t/,'\t');
					@debug.print("ptrn: #{ptrn}");
					indent = Regexp.new(ptrn);
				end
			end
			start = false if start==true;
			s.sub!(indent,'') if indent;
		end
		@debug.print("removed:#{src}");
		return;
	end ##}}}



end
