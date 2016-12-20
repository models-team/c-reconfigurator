package dk.itu.models.tests

import dk.itu.models.Reconfigurator
import dk.itu.models.reporting.ErrorRecord
import dk.itu.models.reporting.Report
import java.io.File
import java.util.ArrayList

import static extension dk.itu.models.Extensions.*

class TestFiles {
	
	static val report = new Report
//	static val source = new File("/home/alex/reconfigurator/c-reconfigurator-test/source/vbdb")
//	static val target = new File("/home/alex/reconfigurator/c-reconfigurator-test/target/vbdb")
//	static val oracle = new File("/home/alex/reconfigurator/c-reconfigurator-test/oracle_new/vbdb")

	static val source = new File("/home/alex/reconfigurator/c-reconfigurator-test/source/libssh_new/0a4ea19/pki.c")
	static val target = new File("/home/alex/reconfigurator/c-reconfigurator-test/target/libssh/0a4ea19/pki.c")
	static val oracle = new File("/home/alex/reconfigurator/c-reconfigurator-test/oracle_new/libssh/0a4ea19/pki.c")
	
	static def void process (File currentFile) {

		val currentFilePath = currentFile.path
		val currentRelativePath = currentFilePath.relativeTo(source.path)
		val currentTargetPath = target + currentRelativePath
		val currentOraclePath = oracle + currentRelativePath + ".ast"
		
		if (currentFile.isDirectory) {
			
			println('''processing directory .«currentRelativePath»/''')
			report.addFolder(currentRelativePath)
			
			val targetDir = new File(currentTargetPath)
			if (!targetDir.exists) targetDir.mkdirs
			
			currentFile.listFiles.filter[isFile].sort.forEach[process(it)]
			
			currentFile.listFiles.filter[isDirectory].sort.forEach[process(it)]

		} else if(currentFilePath.endsWith(".c")) {
			
			println
			println("----------------------------------------------------------------------")
			println('''processing file .«currentRelativePath»''')

			var runArgs = new ArrayList<String>
			
			runArgs.addAll(
				 "-source"	,currentFilePath
				,"-target"	,currentTargetPath
				,"-oracle"	,currentOraclePath
				,"-I"		,currentFile.parent
				
				//libSSH
				,"-I"		,currentFile.parent + "/incl_reconf"
				,"-define"	,"RECONFIGURATOR"
				//libSSH end
				
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/include"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated/uapi" 
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/uapi"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated/uapi" 
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/include/uapi"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/include/generated/uapi"
//				,"-include", "test.h"
				,"-reconfigureIncludes"
//				,"-printIntermediaryFiles"
//				,"-printDebugInfo"
				)
			
			Reconfigurator::main(runArgs)
			val errors = new ArrayList<ErrorRecord>
			Reconfigurator::errors.forEach[
				println(it)
				errors.add(new ErrorRecord(it))
			]
			report.addFile(currentRelativePath, errors)
			
		} else {
			// ignore
		}
	}

	static def void main(String[] args) { 
		
		println("Begin TestFiles")
		
		process(source)
		
		println
		println("----------------------------------------------------------------------")
		println("Printing Summary")
		
		report.printSummary
		
		val passes = report.fileRecords.filter[
			!folder
			&& errors.findFirst[it.error.startsWith("Exception: ")] == null
			&& errors.findFirst[it.error.startsWith("oracle: ")] == null
		].size
		val files = report.fileRecords.filter[!folder].size
		println
		print("[")
		for (var i = 0; i < passes; i++) print("█")
		for (var i = passes; i < files; i++) print("■")
		println("]")
		println(passes + "/" + files)
		
		println("End TestFiles")
		
	}
}