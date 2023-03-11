**description**
tool shell that has a standalone bin folder
**code**
#! /usr/bin/env ruby

require 'rhload';

$version = 'v1';
$bin = File.dirname(File.absolute_path(__FILE__));
$toolhome = File.join(File.dirname($bin),'ruby');
$LOAD_PATH << $toolhome;
$lib = "lib_#{$version}";

rhload "#{$lib}/debugger.rb";
rhload "#{$lib}/exceptions.rb";
rhload "#{$lib}/options.rb";
rhload "#{$lib}/fileoperator.rb";
rhload "#{$lib}/database.rb";
rhload "#{$lib}/mainentry.rb";

debug=Debugger.new(false);
e = MainEntry.new(debug);
$SIG = e.run();
debug.print("program exists with sig: #{$SIG}");
exit $SIG;
