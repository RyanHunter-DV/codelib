**description**
for SV code generate
**codeid**
CodeGenerator
**code**
# A class to generate SV codes, it's a bottom level API that
# can generate codes directly according to input
class CodeGenerator
	attr :debug;

	def initialize(d) ##{{{
		@debug = d;
	end ##}}}

	# return interface instance code, according to:
	# tn->'InterfaceType'
	# i->'instname'
	# ports->'a,b,c'
	def interfaceInst(tn,i,ports) ##{{{
		return %Q|#{tn} #{i}(#{ports});|;
	end ##}}}

	# return code of uvm_config_db, to set
	# t->set type
	# so->scope object, 'null','this' ...
	# ss->scope string, 'menv' ...
	# sn->set name
	# sf->set field
	def configset(t,so,ss,sn,sf) ##{{{
		return %Q|uvm_config_db#(#{t})::set(#{so},"#{ss}","#{sn}",#{sf});|;
	end ##}}}

	# return macro head according to the given name
	def filemacro(fn) ##{{{
		macro = fn.sub(/\./,'__');
		codes = [
			%Q|`ifndef #{macro}|,
			%Q|`define #{macro}|
		];
		return codes;
	end ##}}}
	def filemacroEnd ##{{{
		return ['`endif'];
	end ##}}}

	def declareModule(mn) ##{{{
		return [%Q|module #{mn};|];
	end ##}}}
	def declareModuleEnd ##{{{
		return ['endmodule'];
	end ##}}}

	def moduleInstance(m) ##{{{
		codes=[];
		index=0;
		codes << %Q|#{m.name} #{m.instname}(|;
		m.connections.each_pair do |s,t|
			index+=1;
			if index==m.portnum
				codes << %Q|\t.#{s}(#{t})|;
			else
				codes << %Q|\t.#{s}(#{t}),|;
			end
		end
		codes << ')';
		return codes;
	end ##}}}
end
