
command :store do
	need do
		# @storeneeds = {};
		@storeneeds[:id] = readUserOption(1);
	end
	process do
		id = @storeneeds[:id];
		raise RunException.new("no valid filename specified by -f",3) unless @options[:file];
		@debug.print("get -f: #{@options[:file]}");
		fop = FileOperator.new(@options[:file],@debug);
		cnts = fop.captureContent(@options[:start],@options[:end]);
		@debug.print("id to be stored: #{id}");
		raise RunException.new("codeid #{id} already exists",3) if @db.codeid?(id);
		desc = @sh.getUserDescription;
		@db.store(id,desc,cnts);
	end
end
