package dk.itu.models.rules

import dk.itu.models.Reconfigurator
import dk.itu.models.utils.DeclarationPCPair
import dk.itu.models.utils.FunctionDeclaration
import dk.itu.models.utils.TypeDeclaration
import dk.itu.models.utils.VariableDeclaration
import java.util.ArrayList
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*
import static extension dk.itu.models.Patterns.*

class ReconfigureDeclarationRule extends ScopingRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}
	
	
	
	



	private def Pair<Object> reconfigureTypeDeclarationWithVariabilityAndSignatureVariability(Pair<Object> pair) {
		if (
			!pair.empty
			&& pair.head.is_GNode
			&& pair.head.as_GNode.isTypeDeclarationWithVariability
			&& pair.head.as_GNode.get(1).as_GNode.isTypeDeclarationWithTypeVariability(typeDeclarations)
		) {
			val node = pair.head.as_GNode
			val pc = node.get(0).as_PresenceCondition
			val declarationNode = node.get(1).as_GNode
			val refTypeName = declarationNode.getTypeOfTypeDeclaration
			
			val filtered = typeDeclarations.declarationList(refTypeName).filterDeclarations(refTypeName, pc)
			
			var Pair<Object> newPair = Pair::EMPTY
			
			for(DeclarationPCPair declPair : filtered) {
				val newDeclarationNode = if(!refTypeName.equals(declPair.declaration.name))
						declarationNode.replaceIdentifierVarName(refTypeName, declPair.declaration.name)
					else
						declarationNode
				newDeclarationNode.setProperty("refTypeVariabilityHandled", true)
				newPair = newPair.add(GNode::create("Conditional", pc.and(declPair.pc), newDeclarationNode))
			}
			
			newPair = newPair.append(pair.tail)
			return newPair				
		} else {
			return pair
		}
	}
	
//	private def Pair<Object> reconfigureFunctionDeclarationWithSignatureVariability(Pair<Object> pair) {
//		
////		if (
////			!pair.empty
////			&& pair.head.is_GNode
//////			&& pair.head.as_GNode.isFunctionDeclarationWithSignatureVariability(typeDeclarations)
////			&& pair.head.as_GNode.isFunctionDefinition
//////			&& pair.head.as_GNode.getVariableSignatureTypesOfFunctionDeclaration(typeDeclarations).size > 0
////		) {
////			
////			println
////			println(pair.head.printCode)
////			println
////		}
//		
//		if (
//			!pair.empty
//			&& pair.head.is_GNode
//			&& pair.head.as_GNode.isFunctionDeclarationWithSignatureVariability(typeDeclarations)
//		) {
//			val declarationNode = pair.head.as_GNode
//			val funcName = declarationNode.getNameOfFunctionDeclaration
//			val funcType = declarationNode.getTypeOfFunctionDeclaration
//			val variableSigType = declarationNode.getVariableSignatureTypesOfFunctionDeclaration(typeDeclarations).head
//			
//			println
//			println('''--- reconfiguring [«funcName»] [«variableSigType»]''')
//			println
//			
//			var funcTypeDeclaration = typeDeclarations.getDeclaration(funcType) as TypeDeclaration
//			if (funcTypeDeclaration === null)
//				throw new Exception('''ReconfigureDeclarationRule: type declaration [«funcType»] not found.''')
//			
//			var variableSigTypeDeclaration = typeDeclarations.getDeclaration(variableSigType) as TypeDeclaration
//			if (variableSigTypeDeclaration === null)
//				throw new Exception('''ReconfigureDeclarationRule: type declaration [«variableSigType»] not found.''')
//			
//			var funcDeclaration = functionDeclarations.getDeclaration(funcName) as FunctionDeclaration
//			if (funcDeclaration === null) {
//				funcDeclaration = new FunctionDeclaration(funcName, funcTypeDeclaration)
//				functionDeclarations.put(funcDeclaration)
//			}
//			
//			val filtered = typeDeclarations.declarationList(variableSigType).filterDeclarations(variableSigType, Reconfigurator::presenceConditionManager.newPresenceCondition(true))
//			
//			var Pair<Object> newPair = Pair::EMPTY
//			
//			for(DeclarationPCPair declPair : filtered) {
//				var newDeclarationNode = if(!variableSigType.equals(declPair.declaration.name)) {
//					declarationNode.replaceIdentifierVarName(variableSigType.replace("struct ", "").replace("union ", ""), declPair.declaration.name.replace("struct ", "").replace("union ", ""))
//					} else {
//						declarationNode
//					}
//					
//				newDeclarationNode.setProperty("refTypeVariabilityHandled", true)
//				
//				val newFuncName = funcName + "_V" + (functionDeclarations.declarationList(funcName).size + 1)
//				val newFuncDeclaration = new FunctionDeclaration(newFuncName, funcTypeDeclaration)
//				functionDeclarations.put(funcDeclaration, newFuncDeclaration, declPair.pc)
//				
//				newDeclarationNode = newDeclarationNode.replaceIdentifierVarName(funcName, newFuncName)
//				
//				newPair = newPair.add(newDeclarationNode)
//			}
//			
//			newPair = newPair.append(pair.tail)
//			return newPair
//			
//		} else {
//			return pair
//		}
//	}

	private def Pair<Object> reconfigureFunctionDeclarationWithVariabilityAndSignatureVariability(Pair<Object> pair) {
		if (
			!pair.empty
			&& pair.head.is_GNode
			&& pair.head.as_GNode.isFunctionDeclarationWithVariability
			&& pair.head.as_GNode.get(1).as_GNode.isFunctionDeclarationWithSignatureVariability(typeDeclarations)
		) {
			val node = pair.head.as_GNode
			val pc = node.get(0).as_PresenceCondition
			val declarationNode = node.get(1).as_GNode
			val type = declarationNode.getTypeOfFunctionDeclaration
			
			val varType = declarationNode.getVariableSignatureTypesOfFunctionDeclaration(typeDeclarations).head
			val declarations = typeDeclarations.declarationList(varType).filterDeclarations(type, pc)
			
			var Pair<Object> newPair = Pair::EMPTY
			
			for(DeclarationPCPair declPair : declarations) {
				val newDeclarationNode = declarationNode
					.replaceIdentifierVarName(varType.replace("struct ", ""), declPair.declaration.name.replace("struct ", ""))
				newPair = newPair.add(GNode::create("Conditional", pc.and(declPair.pc), newDeclarationNode))
			}

			newPair = newPair.append(pair.tail)
			return newPair
		} else {
			return pair
		}
	}

	private def Pair<Object> reconfigureVariableDeclarationWithTypeVariability(Pair<Object> pair) {
		if (
			!pair.empty
			&& pair.head.is_GNode
			&& pair.head.as_GNode.isVariableDeclarationWithTypeVariability(typeDeclarations)
		) {
			val node = pair.head.as_GNode
			val declarationNode = node
			val varName = declarationNode.getNameOfVariableDeclaration
			val varType = declarationNode.getTypeOfVariableDeclaration
			
			var varTypeDeclaration = typeDeclarations.getDeclaration(varType) as TypeDeclaration
			if (varTypeDeclaration === null)
				throw new Exception('''ReconfigureDeclarationRule: type declaration [«varType»] not found.''')
			
			var varDeclaration = variableDeclarations.getDeclaration(varName) as VariableDeclaration
			if (varDeclaration === null) {
				varDeclaration = new VariableDeclaration(varName, varTypeDeclaration)
				variableDeclarations.put(varDeclaration)
			}
			
			val filtered = typeDeclarations.declarationList(varType).filterDeclarations(varType, Reconfigurator::presenceConditionManager.newPresenceCondition(true))
			
			var Pair<Object> newPair = Pair::EMPTY
			
			for(DeclarationPCPair declPair : filtered) {
				var newDeclarationNode = if(!varType.equals(declPair.declaration.name)) {
					declarationNode.replaceIdentifierVarName(varType.replace("struct ", "").replace("union ", ""), declPair.declaration.name.replace("struct ", "").replace("union ", ""))
					} else {
						declarationNode
					}
					
				newDeclarationNode.setProperty("refTypeVariabilityHandled", true)
				
				val newVarName = varName + "_V" + (variableDeclarations.declarationList(varName).size + 1)
				val newVarDeclaration = new VariableDeclaration(newVarName, varTypeDeclaration)
				variableDeclarations.put(varDeclaration, newVarDeclaration, declPair.pc)
				
				newDeclarationNode = newDeclarationNode.replaceIdentifierVarName(varName, newVarName)
				newDeclarationNode.setProperty("OriginalPC", node.presenceCondition.and(declPair.pc))
				
				newPair = newPair.add(newDeclarationNode)
			}
			
			newPair = newPair.append(pair.tail)
			return newPair				
		} else {
			return pair
		}
	}

	private def Pair<Object> reconfigureVariableDeclarationWithVariabilityAndTypeVariability(Pair<Object> pair) {
		if (
			!pair.empty
			&& pair.head.is_GNode
			&& pair.head.as_GNode.isVariableDeclarationWithVariability
			&& pair.head.as_GNode.get(1).as_GNode.isVariableDeclarationWithTypeVariability(typeDeclarations)
		) {
			val node = pair.head.as_GNode
			val pc = node.get(0).as_PresenceCondition
			val declarationNode = node.get(1).as_GNode
			val refTypeName = declarationNode.getTypeOfVariableDeclaration
			
			val filtered = typeDeclarations.declarationList(refTypeName).filterDeclarations(refTypeName, pc)
			
			var Pair<Object> newPair = Pair::EMPTY
			
			for(DeclarationPCPair declPair : filtered) {
				val newDeclarationNode = if(!refTypeName.equals(declPair.declaration.name)) {
						declarationNode.replaceIdentifierVarName(refTypeName, declPair.declaration.name)
					} else {
						declarationNode
					}
				newDeclarationNode.setProperty("refTypeVariabilityHandled", true)
				newPair = newPair.add(GNode::create("Conditional", pc.and(declPair.pc), newDeclarationNode))
			}
			
			newPair = newPair.append(pair.tail)
			return newPair				
		} else {
			return pair
		}
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		
		var Pair<Object> newPair = pair
		
		newPair = reconfigureTypeDeclarationWithVariabilityAndSignatureVariability(pair)
		if (newPair !== pair) return newPair
		
//		newPair = reconfigureFunctionDeclarationWithSignatureVariability(pair)
//		if (newPair !== pair) return newPair
		
		newPair = reconfigureFunctionDeclarationWithVariabilityAndSignatureVariability(pair)
		if (newPair !== pair) return newPair
		
		newPair = reconfigureVariableDeclarationWithTypeVariability(pair)
		if (newPair !== pair) return newPair
			
		newPair = reconfigureVariableDeclarationWithVariabilityAndTypeVariability(pair)
		if (newPair !== pair) return newPair
			
		return pair
	}
	






	private def GNode reconfigureTypeDeclarationWithVariability(GNode node) {
		if (
			node.isTypeDeclarationWithVariability
		) {
			val pc = node.get(0).as_PresenceCondition
			val declarationNode = node.get(1).as_GNode
			val typeName = declarationNode.getNameOfTypeDeclaration
			val refTypeName = declarationNode.getTypeOfTypeDeclaration
			
			var refTypeDeclaration = typeDeclarations.getDeclaration(refTypeName) as TypeDeclaration
			if (refTypeDeclaration === null)
				throw new Exception('''ReconfigureDeclarationRule: type declaration [«refTypeName»] not found.''')
			
			var typeDeclaration = typeDeclarations.getDeclaration(typeName) as TypeDeclaration
			if (typeDeclaration === null) {
				typeDeclaration = new TypeDeclaration(typeName, refTypeDeclaration)
				typeDeclarations.put(typeDeclaration)
			}
			
			val newTypeName = typeName + "_V" + (typeDeclarations.declarationList(typeName).size + 1)
			val newTypeDeclaration = new TypeDeclaration(newTypeName, refTypeDeclaration)
			typeDeclarations.put(typeDeclaration, newTypeDeclaration, pc)
			
			var newNode = declarationNode.replaceIdentifierVarName(typeName, newTypeName)
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else {
			return node
		}
	}
	
	private def GNode reconfigureStructUnionTypeDeclarationWithVariability(GNode node) {
		if (
			node.isStructUnionTypeDeclarationWithVariability
		) {
			val pc = node.get(0).as_PresenceCondition
			val declarationNode = node.get(1).as_GNode
			val typeName = declarationNode.getNameOfStructUnionTypeDeclaration
			val refTypeName = declarationNode.getTypeOfStructUnionTypeDeclaration
			
			
			var refTypeDeclaration = typeDeclarations.getDeclaration(refTypeName) as TypeDeclaration
			if (refTypeDeclaration === null && !refTypeName.equals("struct") && !refTypeName.equals("union"))
				throw new Exception('''ReconfigureDeclarationRule: type declaration [«refTypeName»] not found.''')
			
			var typeDeclaration = typeDeclarations.getDeclaration(typeName) as TypeDeclaration
			if (typeDeclaration === null) {
				typeDeclaration = new TypeDeclaration(typeName, refTypeDeclaration)
				typeDeclarations.put(typeDeclaration)
			}
			
			val newTypeName = typeName + "_V" + (typeDeclarations.declarationList(typeName).size + 1)
			val newTypeDeclaration = new TypeDeclaration(newTypeName, refTypeDeclaration)
			typeDeclarations.put(typeDeclaration, newTypeDeclaration, pc)
			
			var newNode = declarationNode.replaceIdentifierVarName(typeName, newTypeName, [rule | !rule.ancestors.exists[it.name.equals("SUEDeclarationSpecifier")]])
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else {
			return node
		}
	}
	
	private def GNode reconfigureStructUnionDeclarationWithVariability(GNode node) {
		if (
			node.isStructUnionDeclarationWithVariability
		) {
			val pc = node.get(0).as_PresenceCondition
			val declarationNode = node.get(1).as_GNode
			val type = declarationNode.getNameOfStructUnionDeclaration
			val name = type.replace("struct ", "").replace("union ", "")
			
			var typeDeclaration = typeDeclarations.getDeclaration(type)
			if (typeDeclaration === null) {
				typeDeclaration = new TypeDeclaration(type, null)
				typeDeclarations.put(typeDeclaration)
			}
			
			val newType = type + "_V" + (typeDeclarations.declarationList(type).size + 1)
			val newName = newType.replace("struct ", "").replace("union ", "")
			
			val newTypeDeclaration = new TypeDeclaration(newType, null)
			typeDeclarations.put(typeDeclaration, newTypeDeclaration, pc)
			
			val newNode = declarationNode.replaceIdentifierVarName(name, newName)
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else {
			return node
		}
	}
	
	private def GNode reconfigureEnumDeclarationWithVariability(GNode node) {
		if (
			node.isEnumDeclarationWithVariability
		) {
			val pc = node.get(0).as_PresenceCondition
			var newNode = node.get(1).as_GNode
			
			for (String enumerator : node.getDescendantNode("EnumeratorList").filter[it.is_GNode("Enumerator")].map[it.as_GNode.get(0).toString]) {
				var enumeratorDeclaration = variableDeclarations.getDeclaration(enumerator)
				if (enumeratorDeclaration === null) {
					enumeratorDeclaration = new VariableDeclaration(enumerator, typeDeclarations.getDeclaration("int") as TypeDeclaration)
					variableDeclarations.put(enumeratorDeclaration)
				}
				
				val newEnumerator = enumerator + "_V" + (variableDeclarations.declarationList(enumerator).size + 1)
				newNode = newNode.replaceIdentifierVarName(enumerator, newEnumerator)
			}
			
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else {
			return node
		}
	}
	
	private def GNode reconfigureFunctionDeclarationWithVariability(GNode node) {
		if (
			node.isFunctionDeclarationWithVariability
		) {
			val pc = node.get(0).as_PresenceCondition
			val declarationNode = node.get(1).as_GNode
			val funcName = declarationNode.getNameOfFunctionDeclaration
			val funcType = declarationNode.getTypeOfFunctionDeclaration
			
			var funcTypeDeclaration = typeDeclarations.getDeclaration(funcType) as TypeDeclaration
			if (funcTypeDeclaration === null)
				throw new Exception('''ReconfigureDeclarationRule: type declaration [«funcType»] not found.''')
			
			var funcDeclaration = functionDeclarations.getDeclaration(funcName) as FunctionDeclaration
			if (funcDeclaration === null) {
				funcDeclaration = new FunctionDeclaration(funcName, funcTypeDeclaration)
				functionDeclarations.put(funcDeclaration)
			}
			
			val newFuncName = funcName + "_V" + (functionDeclarations.declarationList(funcName).size + 1)
			val newFuncDeclaration = new FunctionDeclaration(newFuncName, funcTypeDeclaration)
			functionDeclarations.put(funcDeclaration, newFuncDeclaration, pc)

			var newNode = declarationNode.replaceIdentifierVarName(funcName, newFuncName)
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else {
			return node
		}
	}
	
	private def GNode reconfigureFunctionDefinitionWithVariability(GNode node) {
		if (
			node.isFunctionDefinitionWithVariability
		) {
			val pc = node.get(0).as_PresenceCondition
			val definitionNode = node.get(1).as_GNode
			val funcName = definitionNode.getNameOfFunctionDefinition
			val funcType = definitionNode.getTypeOfFunctionDefinition
			
			var funcTypeDeclaration = typeDeclarations.getDeclaration(funcType) as TypeDeclaration
			if (funcTypeDeclaration === null)
				throw new Exception('''ReconfigureDeclarationRule: type declaration «funcType» not found.''')
			
			var funcDeclaration = functionDeclarations.getDeclaration(funcName) as FunctionDeclaration
			if (funcDeclaration === null) {
				funcDeclaration = new FunctionDeclaration(funcName, funcTypeDeclaration)
				functionDeclarations.put(funcDeclaration)
			}
			
			val newFuncName = funcName + "_V" + (functionDeclarations.declarationList(funcName).size + 1)
			val newFuncDeclaration = new FunctionDeclaration(newFuncName, funcTypeDeclaration)
			functionDeclarations.put(funcDeclaration, newFuncDeclaration, pc)

			var newNode = definitionNode.renameFunctionWithNewId(newFuncName)
			newNode = newNode.rewriteVariableUse(variableDeclarations, node.presenceCondition.and(pc))
			newNode = newNode.rewriteFunctionCall(functionDeclarations, node.presenceCondition.and(pc))
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else {
			return node
		}
	}
	
	private def GNode reconfigureFunctionDefinition(GNode node) {
		if (
			node.isFunctionDefinition
			&& !ancestors.last.name.equals("Conditional")
		) {
			debug("   isFunctionDefinition", true)
			val funcName = node.nameOfFunctionDefinition
			debug("   - " + funcName)
			functionDeclarations.rem(funcName, funcName)
			
			var newpair = Pair.EMPTY
			for (Object child : node.toList) {
				if (
						child.is_GNode("FunctionPrototype")
						||
						(child instanceof Language<?>)
				) {
					newpair = newpair.add(child)
				} else {
					val nodepc = node.presenceCondition
					var newnode = child.as_GNode.rewriteVariableUse(variableDeclarations, nodepc)
					newnode = child.as_GNode.rewriteFunctionCall(functionDeclarations, nodepc)
					newpair = newpair.add(newnode)
				}
			}
			return GNode.createFromPair(
				"FunctionDefinition",
				newpair,
				if (node.properties === null)
					null
				else
					node.properties.toInvertedMap[p | node.getProperty(p.toString)]
				)
		} else {
			return node
		}
	}
	
	private def GNode reconfigureVariableDeclarationWithVariability(GNode node) {
		if (
			node.isVariableDeclarationWithVariability
		) {
			val pc = node.get(0).as_PresenceCondition
			val declarationNode = node.get(1).as_GNode
			val varName = declarationNode.nameOfVariableDeclaration
			val varType = declarationNode.typeOfVariableDeclaration
			
			var varTypeDeclaration = typeDeclarations.getDeclaration(varType) as TypeDeclaration
			if (varTypeDeclaration === null)
				throw new Exception('''ReconfigureDeclarationRule: type declaration [«varType»] not found.''')
			
			var varDeclaration = variableDeclarations.getDeclaration(varName) as VariableDeclaration
			if (varDeclaration === null) {
				varDeclaration = new VariableDeclaration(varName, varTypeDeclaration)
				variableDeclarations.put(varDeclaration)
			}
			
			val newVarName = varName + "_V" + (variableDeclarations.declarationList(varName).size + 1)
			val newVarDeclaration = new VariableDeclaration(newVarName, varTypeDeclaration)
			variableDeclarations.put(varDeclaration, newVarDeclaration, pc)

			var newNode = declarationNode.replaceIdentifierVarName(varName, newVarName)
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else {
			return node
		}
	}
	
	private def GNode reconfigureSelection(GNode node) {
		if (
			// other places to rewrite variable names and function calls
			node.name.equals("SelectionStatement")
		) {
			debug
			debug("   other rewrites", true)
			debug("   - " + node.name)
			val tempNode = node.get(2).as_GNode.rewriteVariableUse(variableDeclarations, node.presenceCondition)
			
			if (!tempNode.printAST.equals(node.get(2).printAST)) {
				return GNode::createFromPair(
					"SelectionStatement",
					node.map[
						if (node.indexOf(it) == 2) tempNode
						else it].toPair)
			} else {
				return node
			}
		} else {
			return node
		}
	}
	
	private def GNode reconfigureIterationCompoundExpression(GNode node) {
		if (
			node.name.equals("IterationStatement")
			|| node.name.equals("CompoundStatement")
			|| node.name.equals("ExpressionStatement")
		) {
			debug
			debug("   other rewrites", true)
			debug("   - " + node.name)
			return node.rewriteVariableUse(variableDeclarations, node.presenceCondition)
		} else {
			return node
		}
	}
	
	private def GNode reconfigureNonVariability(GNode node) {
		if (
			// declarations without variability
			ancestors.size >= 1
			&& #["ExternalDeclarationList", "DeclarationExtension", "DeclarationOrStatementList"].contains(ancestors.last.name)
			&& #["Declaration", "DeclarationExtension"].contains(node.name)
		) {
			node.rewriteVariableUse(variableDeclarations, node.presenceCondition)
		} else {
			return node
		}
	}
	
	override dispatch Object transform(GNode node) {
		// Update the variable scopes and declarations.
		(this as ScopingRule).transform(node)
		
		var GNode newNode = node
		
		newNode = reconfigureTypeDeclarationWithVariability(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureStructUnionTypeDeclarationWithVariability(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureStructUnionDeclarationWithVariability(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureEnumDeclarationWithVariability(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureFunctionDeclarationWithVariability(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureFunctionDefinitionWithVariability(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureFunctionDefinition(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureVariableDeclarationWithVariability(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureSelection(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureIterationCompoundExpression(node)
		if (newNode !== node) return newNode
		
		newNode = reconfigureNonVariability(node)
		if (newNode !== node) return newNode
		
		if (
			// the rest
			#["TranslationUnit", "ExternalDeclarationList", "DeclaringList",
				"SUEDeclarationSpecifier", "DeclarationQualifierList", "StructOrUnionSpecifier",
				"StructOrUnion", "IdentifierOrTypedefName", "SimpleDeclarator", "ArrayDeclarator",
				"ArrayAbstractDeclarator", "InitializerOpt", "Initializer", "StringLiteralList",
				"BasicDeclarationSpecifier", "SignedKeyword", "ParameterTypedefDeclarator",
				"DeclarationQualifier", "TypeQualifier", "AttributeSpecifier", "AttributeKeyword",
				"AttributeListOpt", "AttributeList", "Word", "TypedefDeclarationSpecifier",
				"FunctionPrototype", "FunctionSpecifier", "FunctionDeclarator",
				"PostfixingFunctionDeclarator", "ParameterTypeListOpt", "ParameterTypeList",
				"ParameterList", "ParameterDeclaration", "BasicTypeSpecifier", "TypeQualifierList",
				"TypeQualifier", "ConstQualifier", "DeclarationOrStatementList",
				"ReturnStatement", "MultiplicativeExpression", "CastExpression", "TypeName",
				"TypedefTypeSpecifier", "PrimaryIdentifier", "RelationalExpression",
				"ExpressionStatement", "AssignmentExpression", "AssignmentOperator", "FunctionCall",
				"ExpressionList", "PrimaryExpression", "ConditionalExpression", "LogicalAndExpression",
				"UnaryExpression", "Unaryoperator", "ShiftExpression", "Conditional",
				"UnaryIdentifierDeclarator", "AttributeSpecifierListOpt", "AttributeSpecifierList",
				"AttributeExpressionOpt", "AbstractDeclarator", "UnaryAbstractDeclarator",
				"EqualityExpression", "LogicalORExpression", "RestrictQualifier", "AndExpression",
				"InclusiveOrExpression", "IterationStatement", "AdditiveExpression", "StatementAsExpression",
				"Subscript", "Decrement", "GotoStatement", "BreakStatement", "LabeledStatement", "Increment",
				"MatchedInitializerList", "DesignatedInitializer", "Designation", "DesignatorList",
				"Designator", "ContinueStatement", "Expression", "SUETypeSpecifier",
				"StructDeclarationList", "StructDeclaration", "StructDeclaringList", "StructDeclarator",
				"IndirectSelection", "EmptyDefinition", "EnumSpecifier", "EnumeratorList", "Enumerator",
				"EnumeratorValueOpt", "PostfixIdentifierDeclarator", "PostfixingAbstractDeclarator",
				"CleanTypedefDeclarator", "CleanPostfixTypedefDeclarator", "DirectSelection",
				"AssemblyExpressionOpt", "LocalLabelDeclarationListOpt", "ExpressionOpt",
				"ParameterIdentifierDeclaration", "StructSpecifier", "BitFieldSizeOpt",
				"ParameterAbstractDeclaration", "VolatileQualifier", "UnionSpecifier", "AssemblyStatement",
				"AsmKeyword", "Assemblyargument", "AssemblyoperandsOpt", "Assemblyclobbers", "AssemblyExpression",
				"VarArgDeclarationSpecifier", "VarArgTypeName", "BitFieldSize", "AlignofExpression",
				"Alignofkeyword", "SelectionStatement"
				].contains(node.name)
		) {
			node
		} else {
			println
			println('''------------------------------''')
			println('''- ReconfigureDeclarationRule -''')
			println('''------------------------------''')
			ancestors.forEach[
				println('''- «it.name»''')]
			println(node.printAST)
			println
			throw new Exception("ReconfigureDeclarationRule: unknown declaration : " + node.name + ".")
		}
	}
	
	
	
	private def filterDeclarations(List<DeclarationPCPair> inDeclarations, String typeName, PresenceCondition guardPC) {
		
		val declarations = new ArrayList<DeclarationPCPair>
		
		var disjunctionPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
		for (DeclarationPCPair pair : inDeclarations) {
			val pc = pair.pc
			if (!guardPC.and(pc).isFalse) {
				declarations.add(pair)
				disjunctionPC = pc.or(disjunctionPC)
			}
		}
		
		if (!guardPC.BDD.imp(disjunctionPC.BDD).isOne) {
			declarations.add(new DeclarationPCPair(
				new TypeDeclaration(typeName, null),
				disjunctionPC.not
			))
		}
		
		return declarations
	}
}