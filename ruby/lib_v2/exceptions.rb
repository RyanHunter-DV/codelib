class RunException < Exception
	attr :message;
	attr :signal;
	def initialize msg,s=0
		@message = msg;
		@signal = s;
		@signal = -1 if @signal==0;
	end
	
	def process
		$stderr.puts "[ERROR], #{@message}";
		return @signal;
	end


end