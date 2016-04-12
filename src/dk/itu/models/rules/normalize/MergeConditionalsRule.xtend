package dk.itu.models.rules.normalize

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.util.Pair
import xtc.tree.GNode
import static extension dk.itu.models.Extensions.*

class MergeConditionalsRule extends dk.itu.models.rules.Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if(
			pair.size >= 2
			
			&& pair.head instanceof GNode
			&& (pair.head as GNode).name.equals("Conditional")
			&& (pair.head as GNode).filter(PresenceCondition).size == 1
			
			&& pair.tail.head instanceof GNode
			&& (pair.tail.head as GNode).name.equals("Conditional")
			&& (pair.tail.head as GNode).filter(PresenceCondition).size == 1
			
			&& ((pair.head as GNode).get(0) as PresenceCondition)
				.is((pair.tail.head as GNode).get(0) as PresenceCondition)
		) {
			val newPair = new Pair(
				GNode::createFromPair(
					"Conditional",
					(pair.head as GNode).get(0),
					(pair.head as GNode).toPair.tail
						.append((pair.tail.head as GNode).toPair.tail)	
				),
				pair.tail.tail
			)

			return newPair
		} 
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
}