command :show do
	need do
		cnt = readUserOption(1);
		@debug.print("get cnt: #{cnt}");
		if cnt[0..0]=='/'
			ps = cnt[1..cnt.length-2];
			@debug.print("get search pattern (#{ps})");
			p = Regexp.new(ps);
			@showneeds[:mode]=:search;
			@showneeds[:ptrn]=p;
		else
			@showneeds[:mode]=:display;
			@showneeds[:id] = cnt;
			@debug.print("setting mode: #{@showneeds[:mode]}");
		end
	end

	process do
		@debug.print("getting mode: #{@showneeds[:mode]}");
		if @showneeds[:mode]==:display
			id = @showneeds[:id];
			raise RunException.new("id(#{id}) not exists in database",3) unless @db.codeid?(id);
			@db.display(id);
		elsif @showneeds[:mode]==:search
			p = @showneeds[:ptrn];
			@debug.print("string of pattern: (#{p.source})");
			ids = @db.search(p.source);
			ids.each do |id|
				@db.display(id);
			end
		end
	end
end
