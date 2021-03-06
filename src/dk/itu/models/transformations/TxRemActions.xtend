package dk.itu.models.transformations

import dk.itu.models.rules.phase1normalize.RemActionRule
import dk.itu.models.strategies.TopDownStrategy
import xtc.tree.Node
import dk.itu.models.rules.phase1normalize.RemEmptyNodesRule

class TxRemActions extends Transformation {
	
	override Node transform(Node node) {
						
		val tdn = new TopDownStrategy
		tdn.register(new RemActionRule)
		tdn.register(new RemEmptyNodesRule)
		val result = tdn.transform(node) as Node

		return result
	}
	
}