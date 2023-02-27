# Features
## calling cmd with options
the command name is `cb-sv`, can will be called with a sub-command to specify the behavior, like:
```
cb-sv search [options]
cb-sv insert [options]
...
```
*supported commands:*
- search
- insert
- store
- list, show a specific code with the specified codeid
- int, reserve for interactive command

## store code from specified files
by using of 'store' command, users can store a code segment into database. using command like:
```
cb-sv store -f filename,startline,endline
```
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
## insert code from database, with specified codeid
To insert specific code from database to specific file, if the source code has marks, then a '-o markoverrides' are required.
*command example:*
```
cb-sv insert codeid -o '<replacement for mark0>,<replacement for mark1>'
```

## user interactive mode
by using interactive mode, users can easily setup their new code file through various of codes from data base.
#TBD

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
**codelib** ...
**codetype** method...
**description**
here is description
...
```
here is code
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

# MainEntry
**file** 'lib_v2/mainentry.rb'
**class** `MainEntry`
**require**
```
fileOperator
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
```
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
message = "#{@cmd}PreProcess".to_sym;
return self.send(message,args);
```
## pre process different commands
**api** `storePreProcess(args)`
```
# no pre-process for store
return args;
```
**api** `listPreProcess(args)`
```
@codeid = args.shift;
return args;
```
**api** `searchPreProcess(args)`
```
# pattern used for search actions
@pattern = Regexp.new(args.shift);
return args;
```
**api** `insertPreProcess(args)`
```
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
## processing different commands
- capture code segment from specified file.
- arrange code lib database format.
**api** `storeProcess()`
```
cnts = @fop.captureCodes(@options[:file],@options[:start],@options[:end]);
desc = description();
cnts = marking(cnts) if @options[:mark];
@db.store(@codeid,@options[:type],desc,cnts);
```
details: [[#FileOperator]]

## get marked codes
**api** `marking`
```
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
```
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

**file** `lib_v2/options.rb'
**require**
```
optparse
```
**class** 'Options'
**field**
```
options
```
**api** `initialize(argv,d)`
```ruby
@debug = d;
@options={};
@options[:mark] = false;
opt = Option.new() do |o|
	o.on('-f','--filename=FILENAME','specify filename with line options') do |v|
		fileterFilename(v);
	end
	o.on('-m','--mark','enable mark feature') do |v|
		@options[:mark] = v;
	end
	o.on('-o','--override=REPLACEMENT','set replacement for mark') do |v|
		@options[:ovrd] = v;
	end
	o.on('-t','--type=TYPE','specify the type of code being stored') do |v|
		@options[:type] = v;
	end
end
```
## filterFilename
according to the filename option, which might have the line options, to get the file,start,end options:
**api** `filterFilename(v)`
```
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
**file** 'lib_v2/fileOperator.rb'
**class** `FileOperator`
**field**
```
dbroot
```
**api** `initialize(d)`
```
@dbroot = File.join(#{$toolhome},'db');
```
**api** `captureCodes(fn,s=1,e=-1)`
capturing specific lines from given file
s is start line, e is end line, if e is -1, then will capture until the end of file.
```
fh = File.open(fn,'r');
cnts=[];
all= fh.readlines();
fh.close();
len= all.length;
e=len if e==-1;
all.each_with_index do |i,l|
	if i+1 >= s or i+1 <= e
		cnts << l;
	end
end
cnts.map!{|l| l.chomp;};
return cnts;
```

# DataBase
**file** 'lib_v2/database.rb'
**class** `DataBase`
**field**
```
```
#MARK
#TBD
