class MainEntry
	attr :option;
	attr :exitSig;
	attr :db;
	attr :fop;
	attr :debug;
	def initialize(d)
		@debug = d;
		@option = Options.new(@debug);
		@exitSig = 0;
		@db = DataBase.new(@debug);
		@fop= FileOperator.new(@debug);
	end

	def __help__
		puts "not support";
	end

	# split the given file position string, formatted as:
	# file,s,e or
	# file,s
	# returned by a hash:
	# rtn[:file]
	# rtn[:start]
	# rtn[:end]
	# if no start, then rtn[:start] -> 1
	# if no end, then rtn[:end] -> nil
	def __position__(s)
		rtn = {};
		splitted = s.split(',');
		len = splitted.length;
		if len==1
			rtn[:file] = splitted[0];
			rtn[:start] = 1;
			rtn[:end] = nil;
		elsif len==2
			rtn[:file]=splitted[0];
			rtn[:start]=splitted[1];
			rtn[:start]=1 if rtn[:start].chomp=='';
		else
			rtn[:file]  = splitted[0];
			rtn[:start] = splitted[1];
			rtn[:end]   = splitted[2];
		end
		return rtn;
	end
	# store code
	def __store__ ##{{{
		codeid = @option.codeid;
		raise RunException.new("existing codeid #{codeid}, please use another one",3) if @db.codeid?(codeid);
		ps = __position__(@option.positions[:store]);
		cnts = @fop.contents(ps[:file],ps[:start],ps[:end]);
		@debug.print("get contents tobe stored #{cnts}");
		desc = __description__;
		@db.store(codeid,desc,cnts);
		return;
	end ##}}}
	def __description__
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
		desc.delete_at(0);
		desc.each do |line|
			line.chomp!;
		end
		return desc;
	end

	def __insert__
		#TODO
	end
	def __display__
		#TODO
	end

	def run
		begin
			@db.load();
			__help__    if @option.mode==:help or @option.mode==:idle;
			__store__   if @option.mode==:store;
			__insert__  if @option.mode==:insert;
			__display__ if @option.mode==:display;
		rescue RunException => e
			@exitSig = e.process();
		end

		return @exitSig;
	end

end
