command :insert do
	need do
		@insertneeds[:id] = readUserOption(1);
	end

	process do
		id = @insertneeds[:id];
		raise RunException.new("id(#{id}) not exists",3) unless @db.codeid?(id);
		@debug.print("inserting id: #{id}");
		codes = @db.getcodes(id);
		raise RunException.new("no valid filename specified by -f",3) unless @options[:file];
		fop = FileOperator.new(@options[:file],@debug);
		fop.insertContent(@options[:start],codes);
	end

end