require 'open3'
class DataBase
	attr_accessor :debug;
	attr_accessor :dbhome;
	attr_accessor :dbfiles;
	def initialize(d) ##{{{
		@debug = d;
		@dbhome = File.join($toolhome,'db');
	end##}}}
	def store(codeid,type,desc,cnts) ##{{{
		f = __getfile__(codeid);
		fh = File.open(f,'w');
		fh.write("**codelib** `#{codeid}`\n");
		fh.write("**codetype** `#{type}`\n");
		fh.write("**description**\n");
		desc.each do |l|
			fh.write("#{l}\n");
		end
		fh.write("**code**\n");
		__removeStartIndents__(cnts);
		__removeSVClassScope__(cnts) if type=='method';
		fh.write("```\n");
		cnts.each do |l|
			fh.write("#{l}\n");
		end
		fh.write("```\n");
		fh.close;
	end##}}}
	def __getfile__(id) ##{{{
		return File.join(@dbhome,id+'.md');
	end##}}}
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
	end##}}}
	def __removeSVClassScope__(src) ##{{{
		ptrn = Regexp.new(/\S+::/);
		src.each do |line|
			mdata = ptrn.match(line);
			line.sub!(/\S+::/) if mdata;
		end
		return;
	end##}}}
	def loaddb ##{{{
		@dbfiles = Dir.children(@dbhome);
	end##}}}
	def load(id) ##{{{
		fh = File.open(File.join(@dbhome,"#{id}.md"),'r');
		cnts = fh.readlines()
		cnts.map!{|l| l.chomp;};
		return cnts;
	end##}}}
	def search(ptrn) ##{{{
		cmd = %Q|grep -r "#{ptrn}" #{@dbhome}/|;
		out,err,st = Open3.capture3(cmd);
		@debug.print("grep cmd: #{cmd}");
		@debug.print("find grep: #{out}");
		outs = out.split("\n");
		idptrn = Regexp.new(/^.*\/(\S+)\.md\s*:/);
		matches=[];
		outs.each do |oline|
			mdata = idptrn.match(oline);
			matches << mdata[1] if mdata;
		end
		matches.uniq!;
		return matches;
	end##}}}
end
