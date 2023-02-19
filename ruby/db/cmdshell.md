**description**
common ruby lib for shell operation
**code**
require 'open3'
rhload 'exceptionbase.rb'
module Shell ##{

	@type = :bash;

	## t is used to choose to get the setenv command or
	## directly run the setenv command
	## t=:get, will return the command
	## t=:run, will run this command directly
	def self.setenv var,val,t=:get ##{
		line = '';
		case (@type)
		when :bash
			line = "export #{var}=#{val}:$#{var}";
		when :csh
			line = "setenv #{var} #{val}:$#{var}";
		end
		case (t)
		when :get
			## puts "debug line: #{line}";
			return line;
		when :run
			system("#{line}");
		else
			$stderr.puts "Error, type(#{t}) of setenv not supported";
		end
	end ##}

	def self.getfiles f,l=nil ##{
		cmd = '';
		cmd += "cd #{l};" if (l);
		cmd += "ls #{f}";
		fs = `#{cmd}`.split("\n");
		return fs;
	end ##}

	def self.getAbsoluteFiles f,l=nil ##{
		rtns = [];
		fs = self.getfiles f,l
		fs.each do |f|
			rtns << File.join(l,f);
		end
		return rtns;
	end ##}

	## support multiple paths as args
	def self.makedir *paths ##{
		paths.each do |p|
			next if Dir.exists?(p);
			cmd = "mkdir #{p}";
			out,err,st = Open3.capture3(cmd);
			return [err,st.exitstatus] if st.exitstatus!=0;
		end
		return ['',0];
	end ##}

	def self.createDir d ##{
		pd = File.dirname(d);
		self.createDir(pd) unless Dir.exists?(pd);
		self.makedir d;
		return;
	end ##}

	def self.copy s,t ##{
		tdir = File.dirname(t);
		self.createDir(tdir);
		cmd = "cp #{s} #{t}";
		out,err,st = Open3.capture3(cmd);
		return [err,st.exitstatus];
	end ##}

	def self.exec path,cmd,visible=true ##{
		e = "cd #{path};#{cmd}";
		## puts "shell: #{e}";
		out,err,st = Open3.capture3(e);
		puts out if visible;
		return [err.chomp!,st.exitstatus]
	end ##}

	def self.generate t=:file,n='<null>',*cnts ##{
		##puts "DEBUG, generate file: #{n}"
		##puts "DEBUG, contents: #{cnts}"
		case (t)
		when :file
			fh = File.open(n,'w');
			cnts.each do |l|
				fh.write(l+"\n");
			end
			fh.close;
		else
			$stderr.puts "Error, not support type(#{t})"
		end
	end ##}

	def self.find p,n,ext ##{{{
		"""
		find files according to the given path and name
		"""
		cmd = "find -L #{File.absolute_path(p)} #{ext} -name \"#{n}\"";
		### puts "find cmd: #{cmd}"
		fs,err,st = Open3.capture3(cmd);
		## puts "fs: #{fs}"
		## puts "err: #{err}"
		## puts "st: #{st}"
		if fs==''
			fs = []
		else
			fs = fs.split("\n");
		end
		## puts "[DEBUG], fs: #{fs}"
		return fs;
	end ##}}}

end ##}

class ShellException < ExceptionBase
	def initialize msg='',sig=-1 ##{{{
		super();
		@exitSig=sig;
		@eFlag  ='SHELLF';
		@elevel =:FATAL;
		@extMsg = msg if msg!='';
	end ##}}}
end
