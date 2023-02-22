require 'optparse';

class Options
	# mode: idle,help,store,display,insert
	# idle is doing nothing
	attr_accessor :mode;
	attr_accessor :positions;
	attr_accessor :codeid;
	attr_accessor :pattern;
	attr_accessor :indent;
	attr_accessor :markable;
	attr_accessor :overrides;

	attr :option;
	attr :debug;
	def initialize(d)
		@debug  = d;
		@mode   = :idle;
		@codeid = '';
		@pattern= '';
		@indent =  0;
		@positions = {};
		@overrides = [];
		@option = OptionParser.new() do |opt|
			opt.on('-R','--remove=CODEID','remove codelib in library according to id') do |v|
				@mode = :remove;
				@codeid = v;
			end
			opt.on('-s','--store=CODEID','store mode to record the codes into lib') do |v|
				@mode = :store;
				@codeid = v;
			end
			opt.on('-p','--position=FILENAME,START,END','specify where the source code to be stored') do |v|
				@positions[:store] = v;
			end
			opt.on('-d','--display','display available codes in lib') do |v|
				@mode = :display;
			end
			opt.on('-n','--name=CODEID','the code idname to display available codes in lib') do |v|
				@codeid = v;
			end
			opt.on('-r','--regexp=PATTERN','the pattern for search to display available codes in lib') do |v|
				@pattern = v;
			end
			opt.on('-i','--insert=CODEID','insert available codes into a target ') do |v|
				@mode = :insert;
				@codeid = v;
			end
			opt.on('-I','--indent=NUM','how many tabs will be indented of the inserted codes') do |v|
				@indent = v;
			end
			opt.on('-f','--file=FILENAME,START','target file to be inserted') do |v|
				@positions[:insert] = v;
			end
			opt.on('-h','--help','display command options') do |v|
				@mode = :help;
			end
			opt.on('-m','--marker','enable mark replacement, which will open a file to edit the source') do |v|
				@markable=true;
			end
			opt.on('-o','--overrides="<markerreplacement>"','to insert codelib after marker replacement') do |v|
				markfilter(v);
			end
		end.parse!
	end
	def markfilter(s) ##{{{
		splitted = s.split(',');
		splitted.each do |item|
			raw = item.sub('<','');raw = raw.sub('>','');
			@overrides << raw;
		end
		return;
	end ##}}}

end
