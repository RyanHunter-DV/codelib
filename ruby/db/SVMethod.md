**description**
A class for processing SV methods
**codeid**
SVMethod
**code**
# A class storing SV methods,
# # APIs
# - code(:prototype), return sv code of its prototype
# - code(:body), return sv code for method declaration
class SVMethod


	attr_accessor :type; #:task,:func
	attr_accessor :qualifier;
	attr_accessor :returnType;
	attr_accessor :name;
	attr_accessor :args;
	attr_accessor :container;

	attr :debug;
	attr :procedures;

	def initialize(t,d,cn='',*args) ##{{{
		@type = t.to_sym;
		@container=cn;
		@type = :function if @type==:func;
		@debug= d; @returnType='void'
		message = "#{@type}Setup".to_sym;
		self.send(message,*args);
		@procedures=[];
	end ##}}}

	def procedure(p) ##{{{
		@procedures << p;
	end ##}}}

	# for task: n->name, a->args
	def taskSetup(n,a) ##{{{
		@name = n.to_s;
		@args = a.to_s;
	end ##}}}
	def functionSetup(n,a,r='void') ##{{{
		@name = n.to_s;
		@args = a.to_s;
		@returnType=r.to_s;
	end ##}}}


	# code, return code according to the input usage
	# return of code is array type.
	def code(u) ##{{{
		message = "#{u}Code".to_sym;
		return self.send(message);
	end ##}}}
	def prototypeCode ##{{{
		c = %Q|extern #{@qualifier} #{@type}|;
		c+= %Q| #{@returnType}| if @type==:function;
		c+= %Q| #{@name}(#{@args});|;
		return [c];
	end ##}}}
	def bodyCode ##{{{
		codes=[];
		c = %Q|#{@type}|;
		c+= %Q| #{@returnType}| if @type==:function;
		c+= %Q| #{@container}::| if @container;
		c+= %Q|#{@name}(#{@args});|;
		codes << c;
		@procedures.each do |p|
			codes << p;
		end
		codes << %Q|end#{@type}|;
		return codes;
	end ##}}}

end
