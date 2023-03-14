**description**
for test
**codeid**
testid
**code**
#! /usr/bin/env ruby

require 'rhload';

$version = 'v1';
$toolhome = File.dirname(File.absolute_path(__FILE__));
$lib = "lib";
$LOAD_PATH << File.join($toolhome,$lib);

require "mainentry.rb";

entry = MainEntry.new();
$SIG = entry.run();

puts "program exists with sig: #{$SIG}";
exit $SIG;
