require 'open3';
class DataBase

	attr_accessor :dbhome;
	attr_accessor :dbfiles;


	attr :debug;

	def initialize d
		@debug = d;
		@dbfiles=[];
		@dbhome = File.join($toolhome,'db');
		Dir.mkdir(@dbhome) unless Dir.exists?(@dbhome);
	end

	# according to given id, return the filename of that id
	def dbfile(id) ##{{{
		return "#{id}.md";
	end ##}}}
	# load files into db
	def load
		@dbfiles = Dir.children(@dbhome);
		@debug.print("current dbfiles: #{@dbfiles}");
	end

	def remove(id) ##{{{
		fn = __getfile__(id);
		File.delete(fn);
		return;
	end ##}}}

	def __readlines__(f,s=1,e=-1) ##{{{
		cnts = [];
		fh = File.open(f,'r');
		all= fh.readlines();
		len = all.length;
		e = len if e==-1;
		for i in (s..e)
			cnts << all[i-1];
		end
		return cnts;
	end ##}}}

	def display(id) ##{{{
		f = __getfile__(id);
		cnts = __readlines__(f);
		puts "-"*80;
		puts "# CODELIB - [#{id}]";
		puts "\n";
		cnts.each do |line|
			puts line.chomp;
		end
		puts "-"*80;puts "\n";
		return;
	end ##}}}

	def codeid?(id)
		return true if @dbfiles.include?(id+'.md');
		return false;
	end
	def __getfile__(id) ##{{{
		# raise RunException.new("illegal id specified: #{id}",6) unless codeid?(id);
		return File.join(@dbhome,id+'.md');
	end ##}}}

	# file: <codeid>.md
	# format
	# **description**
	# ...
	# **code**
	# ...
	def store(id,desc,cnts)
		f = __getfile__(id);
		fh = File.open(f,'w');
		fh.write("**description**\n");
		desc.each do |l|
			fh.write("#{l}\n");
		end
		fh.write("**codeid**\n");
		fh.write("#{id}\n");
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
		@debug.print("src: #{src}");
		src.each do |s|
			@debug.print("current s: #{s}");
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

	# filter out the file for input all, which is output of grep results
	# and change it to code id;
	def __filtergrepinfo__(all) ##{{{
		codeids = [];
		all.each do |line|
			splitted = line.split(':');
			codeids << splitted[0];
		end
		codeids.map!{|id| File.basename(id).sub('.md','');};
		codeids.uniq!;
		return codeids;
	end ##}}}

	def getcodes(id) ##{{{
		f = __getfile__(id);
		cnts = __readlines__(f); # return with \n
		capture = false;
		codes= [];
		cnts.each do |l|
			codes << l if capture==true;
			capture = true if /\*\*code\*\*/ =~ l;
		end
		return codes;
	end ##}}}

	def search(ptrn)
		cmd = %Q|grep -rin "#{ptrn}" #{@dbhome}|;
		@debug.print(cmd);
		out,err,st = Open3.capture3(cmd);
		raise RunException.new("pattern search failed(#{err})",8) if st.exitstatus!=0;
		outs = out.split("\n");
		return [] if outs.empty?;
		ids = __filtergrepinfo__(outs); 
		return ids;
	end

end
