**description**
A debugger used while developing a new tool
**code**
class Debugger
	attr_accessor :enabled;
	def initialize(m)
		@enabled = m;
	end

	def print(msg)
		f = caller(1)[0];
		puts "[DEBUG] #{f}: #{msg}" if (@enabled);
	end
end
