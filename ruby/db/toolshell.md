**description**
typical tool shell, by which tool can directly load the includes
**code**
#! /usr/bin/env ruby

require 'rhload';

$version = 'v1';
$toolhome = File.dirname(File.absolute_path(__FILE__));
$lib = "lib_#{$version}";
$LOAD_PATH << File.join($toolhome,$lib);

#rhload "debugger.rb";
rhload "exceptions.rb";
## rhload "options.rb";
## rhload "fileoperator.rb";
## rhload "database.rb";
rhload "mainentry.rb";

begin
	entry = MainEntry.new();
	entry.run();
rescue RunException => e
	e.process;
end

exit 0;
