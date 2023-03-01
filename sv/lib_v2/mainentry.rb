require "fileOperator.rb";
require "options.rb";
require "database.rb";
require "runException.rb";
class MainEntry
	attr_accessor :debug;
	attr_accessor :cmd;
	attr_accessor :codeid;
	attr_accessor :pattern;
	attr_accessor :options;
	attr_accessor :fop;
	attr_accessor :db;
	def initialize(args,d) ##{{{
		@debug = d;
		args= filterCmd(args);
		opt = Options.new(args,@debug);
		@options = opt.options;
		@fop = FileOperator.new(@debug);
		@db  = DataBase.new(@debug);
	end##}}}
	def filterCmd(args) ##{{{
		@cmd = args.shift();
		raise RunException.new("no command specified",4) if @cmd==nil;
		message = "#{@cmd}PreProcess".to_sym;
		return self.send(message,args);
	end##}}}
	def storePreProcess(args) ##{{{
		# no pre-process for store
		return args;
	end##}}}
	def listPreProcess(args) ##{{{
		@codeid = args.shift;
		return args;
	end##}}}
	def searchPreProcess(args) ##{{{
		# pattern used for search actions
		# @pattern = Regexp.new(args.shift);
		@pattern = args.shift;
		return args;
	end##}}}
	def insertPreProcess(args) ##{{{
		@codeid = args.shift;
		return args;
	end##}}}
	def run() ##{{{
		message = "#{@cmd}Process".to_sym;
		self.send(message);
	end##}}}
	def storeProcess() ##{{{
		cnts = @fop.captureCodes(@options[:file],@options[:start],@options[:end]);
		desc = description();
		cnts = marking(cnts) if @options[:mark];
		@db.store(@codeid,@options[:type],desc,cnts);
	end##}}}
	def insertProcess() ##{{{
		# codedb has format: {:id=>'',:type=>'',:desc=>'',:code=>[]}
		codedb = @db.load(@codeid);
		codedb[:code] = replaceMarks(codedb[:code],@options[:ovrd]) if @options[:ovrd];
		info = {:classname=>'',:endclass=>0};
		info = @fop.findEnclosedClass(@options[:file],@options[:start]) if codedb[:type]=='method';
		if info[:classname]
			# methods within class
			heads = filterMethodHead(codedb[:code]);
			heads[0]= "extern "+heads[0];
			insertMethodPrototype(@options[:file],@options[:start],heads);
			addClassScope(codedb[:code][0],info[:classname]);
			insertMethodBody(@options[:file],info[:endclass]+1,codedb[:code]);
		else
			# pure methods
			insertMethodBody(@options[:file],@options[:start],codedb[:code]);
		end
	end##}}}
	def insertMethodPrototype(fn,s,cnts) ##{{{
		cnts.map!{|line| "\t"+line;};
		@fop.insertContents(fn,s,cnts);
		return;
	end##}}}
	def insertMethodBody(fn,s,cnts) ##{{{
		@fop.insertContents(fn,s,cnts);
	end##}}}
	def addClassScope(h,cn) ##{{{
		ptrn = Regexp.new(/(\S+)\s*\(/);
		mdata = ptrn.match(h);
		mn = mdata[1] if mdata;
		h.sub!(mn,"#{cn}::#{mn}");
		return;
	end##}}}
	def filterMethodHead(src) ##{{{
		rtns = [];
		src.each do |l|
			if /\);/=~l
				rtns << l;
				break;
			end
			rtns << l;
		end
		return rtns;
	end##}}}
	def replaceMarks(cnts,ovrd) ##{{{
		replaced = [];
		ovrds = filterOverrides(ovrd);
		cnts.each do |line|
			ptrn = Regexp.new(/\<(\d+)\>/);
			mdata = ptrn.match(line);
			if mdata
				m = mdata[1];
				line.gsub!(/\<\d+\>/,ovrds[m]);
			end
			replaced << line;
		end
		return replaced;
	end##}}}
	def filterOverrides(ovrd) ##{{{
		ovrds = {};
		splitted = ovrd.split(',');
		splitted.each_with_index do |i,o|
			ovrds[i.to_s] = o;
		end
		return ovrds;
	end##}}}
	def searchProcess ##{{{
		codeids = @db.search(@pattern);
		raise RunException.new("nothing matched with '#{@pattern}'",0) if codeids.empty?;
		codeids.each do |codeid|
			cnts = @db.load(codeid);
			puts "-"*60;
			puts cnts.join("\n");
			puts "-"*60;
		end
		return;
	end##}}}
	def marking ##{{{
		cnts = [];
		tmpf = "./.tmpf_cbrb_#{Process.pid}";
		fh = File.open(tmpf,'w');
		fh.write("please enter your marker, format,integer enclosed by <>: <0>\n");
		src.each do |l|
			fh.write("#{l}\n");
		end
		fh.close();
		cmd = "vim #{tmpf}";
		sig = system(cmd);
		@debug.print("get vim return sig: #{sig}");
		if sig!=true
			system("rm -rf #{tmpf}");
			raise RunException.new("description create failed",sig);
		end
		# read description
		fh = File.open(tmpf,'r');
		cnts = fh.readlines();
		fh.close;
		system("rm -rf #{tmpf}");
		cnts.delete_at(0);
		cnts.map!{|line| line.chomp;};
		return cnts;
	end##}}}
	def description ##{{{
		tmpf = "./.tmpf_cbrb_#{Process.pid}";
		fh = File.open(tmpf,'w');
		fh.write("please enter your codeblock description below:");
		fh.close;
		cmd = "vim #{tmpf}";
		sig = system(cmd);
		@debug.print("get vim return sig: #{sig}");
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
	end##}}}
end
