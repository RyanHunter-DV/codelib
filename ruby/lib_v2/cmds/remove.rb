command :remove do
	need do
		@removeneeds[:id] = readUserOption(1);
	end
	process do
		id = @removeneeds[:id];
		raise RunException.new("id(#{id}) not exists in database",3) unless @db.codeid?(id);
		@sh.remove(@db.dbhome,@db.dbfile(id));
	end
end
