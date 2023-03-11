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
		captured=[];
		for i in (s..e) do
			captured << all[i-1].chomp! if i>=s and i<=e;
		end
		return captured;
	end ##}}}
end
