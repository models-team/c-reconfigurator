package dk.itu.models.tests

import dk.itu.models.Settings
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.rules.normalize.ConditionPushDownRule
import dk.itu.models.rules.normalize.ConstrainNestedConditionalsRule
import dk.itu.models.rules.normalize.ExtractInitializerRule
import dk.itu.models.rules.normalize.MergeSequentialMutexConditionalRule
import dk.itu.models.rules.normalize.RemOneRule
import dk.itu.models.rules.normalize.SplitConditionalRule
import dk.itu.models.strategies.TopDownStrategy
import xtc.tree.Node

class Test4 extends Test {
	
	new(String inputFile) {
		super(inputFile)
	}
	
	override transform(Node node) {
		
		writeToFile(node.printCode, file + "base.c")
		writeToFile(node.printAST, file + "base.c.ast")

		println("PHASE 1 - Normalize")
		
		val tdn0 = new TopDownStrategy
		tdn0.register(new RemOneRule)
		tdn0.register(new RemExtraRule)
		tdn0.register(new MergeSequentialMutexConditionalRule)
		tdn0.register(new ConstrainNestedConditionalsRule)
		tdn0.register(new SplitConditionalRule)
		tdn0.register(new ConditionPushDownRule)

		var Node normalized = tdn0.transform(node) as Node
		writeToFile(normalized.printCode, file + "norm.c")
		writeToFile(normalized.printAST, file + "norm.ast")
		
		
		
		println("PHASE 2 - Reconfigure variables")
		
		
		val tdn = new TopDownStrategy
//		tdn.register(new ReconfigureVariableRule)
		tdn.register(new ExtractInitializerRule)
		
		
		var Node varReconfigured = tdn.transform(normalized) as Node
		writeToFile('''#include "«Settings::reconfigFile»"«"\n" + varReconfigured.printCode»''', file)
		writeToFile(varReconfigured.printAST, file + ".ast")
	}
	
}