**description**
A class for processing SV classes
**codeid**
SVClass
**code**

require 'svParams.rb'
require 'svField.rb'
require 'svMethod.rb'
require 'fileOperator.rb'
require 'codeGenerator.rb'


class SVClass
	attr_accessor :classname;
	attr_accessor :basename;
	attr_accessor :filename;
	attr_accessor :fields;
	attr_accessor :methods;
	attr_accessor :params;
	attr_accessor :tparams;
	attr_accessor :uvmtype;

	attr :debug;
	attr :fop;

	def initialize(cn,uvmt=:object,d) ##{{{
		@debug=d;@uvmtype=uvmt;@classname=cn;
		@filename = @classname+'.svh';
		@filename[0..0]=@filename[0..0].downcase;
		@debug.print("filename: #{@filename}");
		@fields={};@methods={};
		builtins;
	end ##}}}

	def builtins ##{{{
		newBuiltin;
		if @uvmtype==:component
			phaseBuiltin('build');
			phaseBuiltin('connect');
			phaseBuiltin('run');
		end
	end ##}}}
	def setupUtils ##{{{
		line = %Q|`uvm_#{@uvmtype}_utils_begin(#{@classname}|;
		params = '';
		params += "#{@tparams.params.join(',')}" if @tparams;
		params += "#{@params.params.join(',')}" if @params;
		line+= %Q|#(#{params})| if params!='';
		line+= ')';
		f = SVField.new(:raw,@debug,line);
		@fields['utils_begin'] = f;
		line = %Q|`uvm_#{@uvmtype}_utils_end|;
		f = SVField.new(:raw,@debug,line);
		@fields['utils_end'] = f;
	end ##}}}
	# setup constructor
	def newBuiltin ##{{{
		a = %Q|string name="#{@classname}"|;
		a+= %Q|,uvm_component parent=null| if @uvmtype==:component;
		m = SVMethod.new(:func,@debug,@classname,'new',a,'');
		c = %Q|\tsuper.new(name|;
		c+= %Q|,parent| if @uvmtype==:component;
		c+= %Q|);|;
		m.procedure(c);
		@methods['new'] = m;
	end ##}}}
	def phaseBuiltin(pn) ##{{{
		t = :func;
		t = :task if pn=='run';
		mn = "#{pn}_phase";
		m = SVMethod.new(t,@debug,@classname,"#{pn}_phase",'uvm_phase phase');
		m.qualifier= 'virtual';
		m.procedure(%Q|\tsuper.#{mn}(phase);|);
		@methods[mn] = m;
	end ##}}}

	def base(bn) ##{{{
		@basename = bn;
	end ##}}}
	def param(*args) ##{{{
		@params = SVParams.new(:param,@debug) unless @params;
		args.each do |pair|
			@params.add(pair);
		end
	end ##}}}
	def tparam(*args) ##{{{
		@tparams = SVParams.new(:tparam,@debug) unless @tparams;
		args.each do |pair|
			@tparams.add(pair);
		end
	end ##}}}

	# fields commands {
	# format:
	# field :scalar, 'int', 'ia'
	def field(t,*args) ##{{{
		f = SVField.new(t,@debug,*args);
		@fields[f.name] = f;
	end ##}}}

	# format:
	# task 'name','args'
	def task(n,a,q='',&block) ##{{{
		@debug.print("task called: #{n}");
		m = SVMethod.new(:task,@debug,@classname,n,a);
		m.qualifier= q if q!='';
		if block_given?
			@debug.print("to call block: #{block.source_location}");
			#code = self.instance_eval &block;
			code = block.call;
			@debug.print("get code: #{code}");
			codes = code.split("\n");
			codes.map!{|l| "\t"+l;};
			m.procedure(codes.join("\n"));
		end

		@debug.print("getting method: #{n}");
		@methods[n.to_s] = m;
	end ##}}}

	# format:
	# func 'name','args','rtn',[q], &block
	def func(n,a,r,q='',&block) ##{{{
		m = SVMethod.new(:func,@debug,@classname,n,a);
		m.qualifier= q if q!='';
		code = block.call;
		@debug.print("get code: #{code}");
		codes = code.split("\n");
		codes.map!{|l| "\t"+l;};
		m.procedure(codes.join("\n"));
		@debug.print("getting method: #{n}");
		@methods[n.to_s] = m;
	end ##}}}

	# }

	def publishCode ##{{{
		codes = [];
		cg = CodeGenerator.new(@debug);

		codes.append(*cg.filemacro(@filename));
		tps = '';ps='';
		tps = @tparams.pairs.join(',') if @tparams;
		ps  = @params.pairs.join(',') if @params;
		codes.append(*cg.declareClass(@classname,tps,ps,@basename));

		@fields.each_value do |f|
			codes.append(*(f.code(:instance).map!{|l| "\t"+l;}));
		end
		@methods.each_value do |m|
			codes.append(*(m.code(:prototype).map!{|l| "\t"+l;}));
		end

		codes.append(*cg.declareClassEnd);
		codes << "\n\n";

		@methods.each_value do |m|
			codes.append(*m.code(:body));
		end

		codes.append(*cg.filemacroEnd);

		return codes;
	end ##}}}
	def buildfile(path,cnts) ##{{{
		@fop = FileOperator.new(path,@filename,@debug,:create=>true);
		@fop.writeContents(cnts);
	end ##}}}
	def finalizeSVClass ##{{{
		setupUtils;
	end ##}}}
end
