class FileOperator
	attr_accessor :dbroot;
	def initialize(d) ##{{{
		@dbroot = File.join($toolhome,'db');
	end##}}}
	def insertContents(fn,s,cnts) ##{{{
		fh = File.open(fn,'r');
		all = fh.readlines();
		fh.close;
		cnts.map!{|l|l+"\n";}; cntr = cnts.reverse;
		all.insert(s,*cntr);
		fh = File.open(fn,'w');
		all.each do |l|
			fh.write(l);
		end
		fh.close();
		return;
	end##}}}
	def captureCodes(fn,s=1,e=-1) ##{{{
		fh = File.open(fn,'r');
		cnts=[];
		all= fh.readlines();
		fh.close();
		len= all.length;
		e=len if e==-1;
		all.each_with_index do |i,l|
			if i+1 >= s or i+1 <= e
				cnts << l;
			end
		end
		cnts.map!{|l| l.chomp;};
		return cnts;
	end##}}}
	def findEnclosedClass(fn,s) ##{{{
		info = {:classname=>'',:endclass=>0};
		fh = File.open(fn,'r');
		cnts = fh.readlines();
		ptrn = Regexp.new(/^\s*\w*\s*class\s+(\S+)/);
		cnts.each_with_index do |i,l|
			mdata = ptrn.match(l);
			info[:classname] = mdata[1] if i+1<s and mdata;
			info[:endclass] = i+1 if i+1>s and info[:classname] and /endclass/=~l;
		end
		return info;
	end##}}}
end
