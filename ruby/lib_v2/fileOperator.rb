require 'debugger.rb'
class FileOperator
	attr_accessor :filename;

	attr :debug;
	def initialize(fn,d=nil) ##{{{
		@debug = d;
		@debug = Debugger.new(false) if d==nil;
		@filename = fn;
	end ##}}}

	def captureContent(s=1,e=-1) ##{{{
		fh = File.open(@filename,'r');
		all = fh.readlines(); fh.close;
		e = all.length if e==-1;
		@debug.print("capture range: #{s} -> #{e}");
		captured=[];
		for i in s..e do
			captured << all[i-1].chomp! if i>=s and i<=e;
		end
		return captured;
	end ##}}}

	def insertContent(s=1,cnts) ##{{{
		@debug.print("insert to: #{@filename},#{s}");
		puts "insert cnts: #{cnts}";
		fh = File.open(@filename,'r');
		origin = fh.readlines();fh.close;
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
		new.append(*cnts) if origin.empty?;
		fh = File.open(@filename,'w');
		new.each do |l|
			fh.write(l);
		end
		fh.close;
	end ##}}}
end
