package dk.itu.models

import dk.itu.models.preprocessor.Preprocessor
import dk.itu.models.tests.Test
import dk.itu.models.tests.Test5
import java.io.File
import java.util.ArrayList
import java.util.Map
import org.apache.commons.io.FileUtils
import xtc.lang.cpp.PresenceConditionManager

import static extension dk.itu.models.Extensions.*
import dk.itu.models.tests.Test4

class Reconfigurator {
	
	// per test settings
	static public var Test test
	static public var PresenceConditionManager presenceConditionManager
	static public var Map<String, String> transformedFeaturemap
	static public var Preprocessor preprocessor
	
	def static void run(Test test) {
		Reconfigurator::test = test
		var args = #[
			"-silent",
//			"-Onone",
//			"-naiveFMLR",
//			"-lexer",
			"-no-exit",
			"-U", "__cplusplus",
//			"-showActions",
//			"-follow-set",
//			"-printAST",
//			"-printSource",
			"-saveLayoutTokens",
			"-nostdinc",
			"-showErrors"
//			"-headerGuards",
//			"-macroTable",
//			"-E",
		]
		
		var newArgs = new ArrayList<String>
		newArgs.addAll(args)
		for (File include : Settings::includeFiles) {
			newArgs.addAll("-I", include.path) }
		
		test.run(newArgs)
	}
	
	def static void reconfigure(File currentFile, (String)=>Test test) {
		val currentRelativePath = currentFile.path.relativeTo(Settings::sourceFile.path)
		val currentTargetPath = Settings::targetFile + currentRelativePath

		if(currentFile.isDirectory) {
			val targetDir = new File(currentTargetPath)
			if (!targetDir.exists) {
				println('''making directory .«currentRelativePath»''')
				targetDir.mkdirs
				summaryln('''| md    |       |       |       | .«currentRelativePath»''')
			}
			currentFile.listFiles.filter[isFile].forEach[reconfigure(test)]
			currentFile.listFiles.filter[isDirectory].forEach[reconfigure(test)]
		}
		else {
			var File oracle = null
			if(Settings::oracleFile != null) {
				oracle = new File(currentFile.path.replace(Settings::sourceFile.path, Settings::oracleFile.path) + ".ast")
			}
			if (
				(!Settings::oracleOnly || oracle != null && oracle.exists)
				&& (currentFile.path.endsWith(".c") || currentFile.path.endsWith(".h"))
			) {
				println
				println('''processing file  .«currentRelativePath»''')
				flushConsole
				Settings::consolePS.flush
				
				preprocessor.runFile(currentFile.path).toString.writeToFile(currentTargetPath)
				test.apply(currentTargetPath).run
				
				val sum_console = Settings::consoleBAOS.toString
				val sum_parse =
					if (sum_console.contains("error: parse error")) " ERR   "
					else ( if (sum_console.contains("Exception")) 	" EXCPT "
					else 											" OK    ")
				val sum_check1 =
					if (sum_console.contains("check: ContainsIf1")) " #if1  "
					else 											"       "
				var sum_result =
					if (sum_console.contains("result: #if")) 			"   #if "
					else (if (sum_console.contains("result: no#if")) 	" no#if "
					else 												"   -   ")
					
				var sum_oracle =
					if (sum_console.contains("oracle: pass")) 			" Opass "
					else (if (sum_console.contains("oracle: fail")) 	" Ofail "
					else 												" O-    ")
				summaryln('''|«sum_parse»|«sum_check1»|«sum_oracle»|«sum_result»| .«currentRelativePath»''')
			}
			else {
				println
				println('''ignoring file    .«currentRelativePath»''')
				//FileUtils.copyFile(file, new File(targetPath))
				summaryln('''| ig    |       |       |       | .«currentRelativePath»''')
			}
		}
	}
	
	def static void main(String[] args) {
		Settings::captureOutput
		println("Reconfigurator START")
		println("-- Models Team : ITU.dk (2016) --")
		println
		
		try {
			var actualArgs = args
			
//			actualArgs = #[
//				"-source",  "D:\\eclipse_xtc_test\\test-source\\rule-tests\\vars2.c",
//				"-target",  "D:\\eclipse_xtc_test\\test-target\\rule-tests\\vars2.c"
//			]
//			val (String)=>Test test = [String f | new Test4(f)]
			
			
			
//			actualArgs = #[
//				"-source",  "D:\\repos\\reconfigurator-vbdb\\linux\\simple\\0dc77b6.c",
//				"-target",  "D:\\repos\\reconfigurator-vbdb\\linux\\simple-target\\0dc77b6.c"
//			]
//			val (String)=>Test test = [String f | new Test5(f)]
	
	
	
//			actualArgs = #[
//				"-source",  "D:\\repos\\reconfigurator-vbdb\\testfiles\\variables\\scope_1.c",
//				"-target",  "D:\\repos\\reconfigurator-vbdb\\testfiles-target\\variables\\scope_1.c",
//				"-oracle",  "D:\\repos\\reconfigurator-vbdb\\testfiles-oracle\\variables\\scope_1.c"
//			]
//			val (String)=>Test test = [String f | new Test5(f)]
			
			
			
			actualArgs = #[
				"-source",  "D:\\repos\\reconfigurator-vbdb\\testfiles\\variables\\",
				"-target",  "D:\\repos\\reconfigurator-vbdb\\testfiles-target\\variables\\",
				"-oracle",  "D:\\repos\\reconfigurator-vbdb\\testfiles-oracle\\variables\\"//,
//				"-oracleOnly"
			]
			val (String)=>Test test = [String f | new Test5(f)]
	
			
			
			if (!Settings::init(actualArgs)) throw new Exception("Settings initialization error.");
			
			if (Settings::targetFile.isDirectory) {
				FileUtils.deleteDirectory(Settings::targetFile)
				Settings::targetFile.mkdir
				}
			else { 
				Settings::targetFile.delete
				Settings::reconfigFile.delete
				Settings::consoleFile.delete
				Settings::summaryFile.delete
				Settings::targetFile.parentFile.mkdir
			}
			
			preprocessor = new Preprocessor
			transformedFeaturemap = preprocessor.mapFeatureAndTransformedFeatureNames
			
			summaryln('''----------------------------------------------------------------''')
			summaryln('''| PARSE | CHEK1 | ORACL | #IFS | FILE --------------------------''')
			summaryln('''----------------------------------------------------------------''')
			reconfigure(Settings::sourceFile, test)
			summaryln('''----------------------------------------------------------------''')
			
			println('''writing file     .«Settings::reconfigFile.path.relativeTo(Settings::targetFile.path)»''')
			preprocessor.writeReconfig(Settings::reconfigFile.path)
		} catch (Exception ex) {
			print(ex)
		}
			
		println
		println("Reconfigurator DONE")
		
		
		flushConsole
		
		Settings::systemOutPS.append(Settings::consoleBAOS.toString)
		Settings::systemOutPS.flush
		
		Settings::summaryBAOS.toString.writeToFile(Settings.summaryFile.path)
		Settings::systemOutPS.append(Settings::summaryBAOS.toString)
		Settings::systemOutPS.flush
	}

}
