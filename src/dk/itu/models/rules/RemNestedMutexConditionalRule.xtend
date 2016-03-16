package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class RemNestedMutexConditionalRule extends AncestorGuaranteedRule {

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if(
			!pair.empty &&
			
			(pair.head instanceof GNode) &&
			(pair.head as GNode).name.equals("Conditional") &&
			(pair.head as GNode).filter(PresenceCondition).size == 1 &&
			
			((pair.head as GNode).guard as PresenceCondition).isMutuallyExclusive((pair.head as GNode).get(0) as PresenceCondition)
		)
			pair.tail
		else		
			pair
	}

	override dispatch Object transform(GNode node) {
		node
	}
}