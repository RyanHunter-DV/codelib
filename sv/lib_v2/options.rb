require "optparse";
class Options
	attr_accessor :options;
	def initialize(argv,d) ##{{{
		@debug = d;
		@options={};
		@options[:mark] = false;
		@options[:ovrd] = '';
		opt = OptionParser.new() do |o|
			o.on('-f','--filename=FILENAME','specify filename with line options') do |v|
				fileterFilename(v);
			end
			o.on('-m','--mark','enable mark feature') do |v|
				@options[:mark] = v;
			end
			o.on('-o','--override=REPLACEMENT','set replacement for mark') do |v|
				# type of override: -o "a,b,c"
				@options[:ovrd] = v;
			end
			o.on('-t','--type=TYPE','specify the type of code being stored') do |v|
				@options[:type] = v;
			end
		end.parse!
	end##}}}
	def filterFilename(v) ##{{{
		splitted = v.split(',');
		len = splitted.length;
		if len==1
			@options[:file] = splitted[0];
			@options[:start]=  1;
			@options[:end]  = -1; # -1 is the end of file.
		elsif len==2
			@options[:file] = splitted[0];
			@options[:start]= splitted[1];
			@options[:end]  = -1;
		elsif len==3
			@options[:file] = splitted[0];
			@options[:start]= splitted[1];
			@options[:end]  = splitted[2];
		end
		return;
	end##}}}
end
