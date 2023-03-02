# Features
by using of a shared database, users can customize their own codes easily.
## calling cmd with options
the tool executor name is `cb-sv`, can  be called with a sub-command to specify the behavior, like:
```
cb-sv search [options]
cb-sv insert [options]
```
*support commands:*
- search, search the  database with specific patterns;
- insert, insert codes from database to target file;
- store, capture code segment from existing file, and store to database for sharing;
- list, show a specific code with the specified codeid;
- int, reserve for interactive command;

## store code from specified files
by using of 'store' command, users can store a code segment into database. And the 'store' sub-command support optional options for specific opeartions.
#TODO


### mark and replacement feature
set a mark while storing the code by -m switch, which will create a temporary file that contains code for
storing, and users are free to setup marks like: `<0>`,`<1>`
*command example:*
```
cb-sv store -f filename,startline,endline -m
```
## search with specific information
the search command supports to search information within the database, the pattern supports regexp pattern as ruby program
*command example:*
```
cb-sv search '\w+\s+has information'
```
## list code with specified codeid
*command example:*
```
cb-sv list codeid
```
## insert code from database
To insert specific code from database to specific file.  

## user interactive mode
#TBD
by using interactive mode, users can easily setup their new code file through various of codes from data base.
The interactive feature allows users to assemble their own codes from multiple codeids. However, this feature will create a temporary file.
By calling the 'int' sub-command, users can enter into interactive mode, which will have following commands to operate:
- search, searching contents with specific pattern;
- insert, insert specific codeid's codes into a temporary file;
	- insert from codelib, with/without marks.
	- insert from user input, raw codes.
- flush, to flush the inserted codes into a file;
- help, help information.
- modify, modify a pattern matched string with the substitute string


# Use Cases
## specify code type when storing
use '-t type' to specify the type of the code, currently supports:
- method
- class
- module
- interface
## formats in codelib database
---
database file:
\*\*codelib\*\* ...
\*\*codetype\*\* method...
\*\*description\*\*
here is description
...
\*\*code\*\*
```
here is code
function void build_phase(
	uvm_phase phase,
	string api
);
	super.build_phase(phase);
endfunction
```
---

# Architecture
## Major Procedures
1. in main shell: cb-sv, call e =MainEntry.new();e.run()
2. start the begin-end to catch the exceptions of this tool
3. in MainEntry's initialize, setup options
4. in MainEntry's run, according to different mode, do following:
5. store mode, to store code
6. #TBD



# ToolShell
**file** `cb-sv`
**rbcode** `toolshell`


# MainEntry
**file** `lib_v2/mainentry.rb`
**class** `MainEntry`
**require**
```
fileOperator.rb
options.rb
database.rb
runException.rb
```
**field**
```
debug
cmd
codeid
pattern
options
fop
db
```
## constructor
**api** `initialize(args,d)`
```ruby
@debug = d;
args= filterCmd(args);
opt = Options.new(args,@debug);
@options = opt.options;
@fop = FileOperator.new(@debug);
@db  = DataBase.new(@debug);
```
details of option: [[#Options]];

## filterCmd
this api to filter out the first command in user ARGV. Then according
to different command, gets the first argument.
return the remained args, which are classic option formats, and
feed it to option parser to process remaining options.
**api** `filterCmd(args)`
```ruby
@cmd = args.shift();
raise RunException.new("no command specified",4) if @cmd==nil;
message = "#{@cmd}PreProcess".to_sym;
return self.send(message,args);
```
## pre process different commands
**api** `storePreProcess(args)`
```ruby
@codeid = args.shift;
return args;
```
**api** `listPreProcess(args)`
```ruby
@codeid = args.shift;
return args;
```
**api** `searchPreProcess(args)`
```ruby
# pattern used for search actions
@pattern = args.shift;
return args;
```
**api** `insertPreProcess(args)`
```ruby
@codeid = args.shift;
return args;
```

## run
- according to cmd ,do different commands, by calling different methods
**api** `run()`
```ruby
message = "#{@cmd}Process".to_sym;
self.send(message);
```
details: [[#FileOperator]]
## processing store command
**api** `storeProcess()`
- capture code segment from specified file.
- arrange code lib database format.
```ruby
cnts = @fop.captureCodes(@options[:file],@options[:start],@options[:end]);
desc = description();
cnts = marking(cnts) if @options[:mark];
raise RunException.new("no codeid specidied",5) if not @codeid;
@db.store(@codeid,@options[:type],desc,cnts);
```
## process insert command
**api** `insertProcess()`
- by given options, get code from db, and insert to target file
- if has -o option, need to process mark replacement
- if type is method, need to search the target file, if given line is within a class
- then insert this method into that class.
```ruby
# codedb has format: {:id=>'',:type=>'',:desc=>'',:code=>[]}
codedb = @db.load(@codeid);
codedb[:code] = replaceMarks(codedb[:code],@options[:ovrd]) if @options[:ovrd];
if codedb[:type] =='method'
	info = {:classname=>'',:endclass=>0};
	info = @fop.findEnclosedClass(@options[:file],@options[:start]);
	if info[:classname]
		# methods within class
		heads = filterMethodHead(codedb[:code]);
		heads[0]= "extern "+heads[0];
		insertMethodPrototype(@options[:file],@options[:start],heads);
		addClassScope(codedb[:code][0],info[:classname]);
		insertMethodBody(@options[:file],info[:endclass]+1,codedb[:code]);
	else
		# pure methods
		insertMethodBody(@options[:file],@options[:start],codedb[:code]);
	end
	else
	@fop.insertContents(@options[:file],@options[:start],codedb[:code]);
end
```
**api** `insertMethodPrototype(fn,s,cnts)`
```ruby
cnts.map!{|line| "\t"+line;};
@fop.insertContents(fn,s,cnts);
return;
```
**api** `insertMethodBody(fn,s,cnts)`
```ruby
@fop.insertContents(fn,s,cnts);
```
**api** `addClassScope(h,cn)`
- add the head of method from database with class scope
```ruby
ptrn = Regexp.new(/(\S+)\s*\(/);
mdata = ptrn.match(h);
mn = mdata[1] if mdata;
h.sub!(mn,"#{cn}::#{mn}");
return;
```
**api** `filterMethodHead(src)`
```ruby
rtns = [];
src.each do |l|
	if /\);/=~l
		rtns << l;
		break;
	end
	rtns << l;
end
return rtns;
```

**api** `replaceMarks(cnts,ovrd)`
```ruby
replaced = [];
ovrds = filterOverrides(ovrd);
cnts.each do |line|
	ptrn = Regexp.new(/\<(\d+)\>/);
	mdata = ptrn.match(line);
	if mdata
		m = mdata[1];
		line.gsub!(/\<\d+\>/,ovrds[m]);
	end
	replaced << line;
end
return replaced;
```

**api** `filterOverrides(ovrd)`
```ruby
ovrds = {};
splitted = ovrd.split(',');
splitted.each_with_index do |i,o|
	ovrds[i.to_s] = o;
end
return ovrds;
```

## process search command
**api** `searchProcess`
```ruby
codeids = @db.search(@pattern);
raise RunException.new("nothing matched with '#{@pattern}'",0) if codeids.empty?;
codeids.each do |codeid|
	codedb = @db.load(codeid);
	puts "-"*60;
	puts codedb[:code].join("\n");
	puts "-"*60;
end
return;
```
## get marked codes
**api** `marking`
```ruby
cnts = [];
tmpf = "./.tmpf_cbrb_#{Process.pid}";
fh = File.open(tmpf,'w');
fh.write("please enter your marker, format,integer enclosed by <>: <0>\n");
src.each do |l|
	fh.write("#{l}\n");
end
fh.close();
cmd = "vim #{tmpf}";
sig = system(cmd);
@debug.print("get vim return sig: #{sig}");
if sig!=true
	system("rm -rf #{tmpf}");
	raise RunException.new("description create failed",sig);
end
# read description
fh = File.open(tmpf,'r');
cnts = fh.readlines();
fh.close;
system("rm -rf #{tmpf}");
cnts.delete_at(0);
cnts.map!{|line| line.chomp;};
return cnts;
```

## get description for store code
**api** `description`
```ruby
tmpf = "./.tmpf_cbrb_#{Process.pid}";
fh = File.open(tmpf,'w');
fh.write("please enter your codeblock description below:");
fh.close;
cmd = "vim #{tmpf}";
sig = system(cmd);
@debug.print("get vim return sig: #{sig}");
if sig!=true
	system("rm -rf #{tmpf}");
	raise RunException.new("description create failed",sig);
end
# read description
fh = File.open(tmpf,'r');
desc = fh.readlines();
fh.close;
system("rm -rf #{tmpf}");
desc.delete_at(0);
desc.each do |line|
	line.chomp!;
end
return desc;
```

# Options
An option processor leverage the standard OptionParser, with a given argv, which is pre-processed by MainEntry.

**file** `lib_v2/options.rb`
**require**
```
optparse
```
**class** `Options`
**field**
```
options
```
**api** `initialize(argv,d)`
```ruby
@debug = d;
@options={};
@options[:mark] = false;
@options[:ovrd] = '';
opt = OptionParser.new() do |o|
	o.on('-f','--filename=FILENAME','specify filename with line options') do |v|
		filterFilename(v);
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
```
## filterFilename
according to the filename option, which might have the line options, to get the file,start,end options:
**api** `filterFilename(v)`
```ruby
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
```

# FileOperator
**file** `lib_v2/fileOperator.rb`
**class** `FileOperator`
**field**
```
dbroot
```
**api** `initialize(d)`
```ruby
@dbroot = File.join($toolhome,'db');
```
**api** `insertContents(fn,s,cnts)`
```ruby
fh = File.open(fn,'r');
all = fh.readlines();
fh.close;
cnts.map!{|l|l+"\n";}; cntr = cnts.reverse;
all.insert(s.to_i,*cnts);
fh = File.open(fn,'w');
all.each do |l|
	fh.write(l);
end
fh.close();
return;
```

**api** `captureCodes(fn,s=1,e=-1)`
capturing specific lines from given file
s is start line, e is end line, if e is -1, then will capture until the end of file.
```ruby
s=s.to_i;e=s.to_i;
fh = File.open(fn,'r');
cnts=[];
all= fh.readlines();
fh.close();
len= all.length;
e=len if e==-1;
all.each_with_index do |l,i|
	if i+1 >= s or i+1 <= e
		cnts << l;
	end
end
cnts.map!{|l| l.chomp;};
return cnts;
```
## find enclosed classname and endclass line
according to given file, and line, find if current line is enclosed by a class
**api** `findEnclosedClass(fn,s)`
```ruby
info = {:classname=>'',:endclass=>0};
fh = File.open(fn,'r');
cnts = fh.readlines();
ptrn = Regexp.new(/^\s*\w*\s*class\s+(\S+)/);
cnts.each_with_index do |i,l|
	mdata = ptrn.match(l);
	info[:classname] = mdata[1] if i+1<s and mdata;
	info[:endclass] = i+1 if i+1>s and info[:classname] and /endclass/=~l;
end
return info;
```

# DataBase
**file** `lib_v2/database.rb`
**class** `DataBase`
**require**
```
open3
```
**field**
```
debug
dbhome
dbfiles
```
**api** `initialize(d)`
```ruby
@debug = d;
@dbhome = File.join($toolhome,'db');
```
**api** `store(codeid,type,desc,cnts)`
```ruby
Dir.mkdir(@dbhome) unless Dir.exists?(@dbhome);
f = __getfile__(codeid);
fh = File.open(f,'w');
fh.write("**codelib** `#{codeid}`\n");
fh.write("**codetype** `#{type}`\n");
fh.write("**description**\n");
desc.each do |l|
	fh.write("#{l}\n");
end
fh.write("**code**\n");
__removeStartIndents__(cnts);
__removeSVClassScope__(cnts) if type=='method';
fh.write("```\n");
cnts.each do |l|
	fh.write("#{l}\n");
end
fh.write("```\n");
fh.close;
```

**api** `__getfile__(id)`
```ruby
return File.join(@dbhome,id+'.md');
```

**api** `__removeStartIndents__(src)`
```ruby
start  = true;
indent = nil;
m = nil;
src.each do |s|
	if start==true
		m = /(^\t*)/.match(s);
		if m
			ptrn = "^"+m[1].gsub(/\t/,'\t');
			@debug.print("ptrn: #{ptrn}");
			indent = Regexp.new(ptrn);
		end
	end
	start = false if start==true;
	s.sub!(indent,'') if indent;
end
@debug.print("removed:#{src}");
return;
```
**api** `__removeSVClassScope__(src)`
```ruby
ptrn = Regexp.new(/\S+::/);
src.each do |line|
	mdata = ptrn.match(line);
	line.sub!(/\S+::/) if mdata;
end
return;
```
**api** `loaddb`
```ruby
@dbfiles = Dir.children(@dbhome);
```

**api** `load(id)`
load specific id codes and return to caller
```ruby
codedb={};
fh = File.open(File.join(@dbhome,"#{id}.md"),'r');
cnts = fh.readlines()
cnts.map!{|l| l.chomp;};
mark = :head;
codedb[:code]=[];
codedb[:type]=:default;
cnts.each do |l|
	mdata = /\*\*codetype\*\* `(\S+)`/.match(l);
	codedb[:type] = mdata[1] if mdata;
	codedb[:code] << l if (mark==:code);
	mark=:code if /\*\*code\*\*/=~l;
end
codedb[:code].delete_if{|item| item=='```'};
return codedb;
```

## search pattern from codelib
**api** `search(ptrn)`
```ruby
cmd = %Q|grep -r "#{ptrn}" #{@dbhome}/|;
out,err,st = Open3.capture3(cmd);
@debug.print("grep cmd: #{cmd}");
@debug.print("find grep: #{out}");
outs = out.split("\n");
idptrn = Regexp.new(/^.*\/(\S+)\.md\s*:/);
matches=[];
outs.each do |oline|
	mdata = idptrn.match(oline);
	matches << mdata[1] if mdata;
end
matches.uniq!;
return matches;
```

# Debugger
**file** `lib_v2/debugger.rb`
**rbcode** `debugger`

# RunException
**file** `lib_v2/runException.rb`
**rbcode** `RunException`

#TBD
