- a tool can gather a code block from certain line~line according to user option, store into CodePool and give it a name.
- can display to screen according to the id name, or some of key words matched
- can insert the code block into a specified file from certain line.

This will be a separate tool into GitHub, made by ruby.
tool name: cb-rb

# Features
## marker that can use replacement
code block stored with markers and can be replaced while inserting those markers, example:
```
**block** file
<0> = File.join(<1>,<2>);
**block** shellcmd
class ShellCmd

	...

end
**block** runexception
class RunException < Exception
...
end
**block** exeshell


---
>> file full p f
```

# Examples
## store ruby codes to lib

```
>> cb-rb -s codename -p filename,1,10
```
while storing code, if the first line is indented, then all lines of the indents will be removed until the first line is not indented, which means following code:
```
	def help
		puts "help";
	end
```
will be stored as:
```
def help
	puts "help";
end
```
## display ruby codes in lib
*by with code name*
```
>> cb-rb -d -n shellcmd
```
*searching code block*
by searching mode, can search keywords in code or in description, according to what users provided
```
>> cb-rb -d -r "codeblock for processing shellcmd"
```
*or*:
```
>> cb-rb -d -r 'regexp'
```

## insert ruby codes
```
>> cb-rb -i shellcmd -I 2 -f filename,2
```
- default has no indent only if specified by `-I`
- if user specifies '-f' with only filename, then it will be inserted from line 1

*inserted as a new file*
```
>> cb-rb -i shellcmd -f filename
```
