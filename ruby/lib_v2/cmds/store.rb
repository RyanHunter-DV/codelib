
command :store do
	id = readUserOption(1);
	fop = FileOperator.new(options[:file],@debug);
	cnts = fop.captureContent(options[:start],options[:end]);
	raise RunException.new("codeid #{id} already exists",3) if @db.codeidExists(id);
	desc = @sh.getUserDescription;
	@db.store(id,desc,cnts);
end