package dk.itu.models.rules.phase1normalize

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*
import dk.itu.models.Reconfigurator

class ConstrainNestedConditionalsRule extends dk.itu.models.rules.AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}

	override dispatch Object transform(GNode node) {
		// Visit a Conditional
		// with a single PresenceCondition.
		if  (  node.name.equals("Conditional")
			&& node.filter(PresenceCondition).size == 1
		) {
			val currentPC = node.get(0).as_PresenceCondition
			val ancestorPC = node.presenceCondition
			val simplifiedPC = Reconfigurator::presenceConditionManager.newPresenceCondition(currentPC.getBDD.constrain(ancestorPC.getBDD))
			
			if (!simplifiedPC.is(currentPC))
			{
				return GNode::createFromPair("Conditional", simplifiedPC, node.toPair.tail)
			}
		}
		node
	}
}