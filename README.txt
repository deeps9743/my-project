==================== Batch job execution: ====================
To execute xls on recursive file from a given module path following command can be used
# ./FixShortName.bat "C:\Projects\ACG-9.3.1"

==================== Unit level execution: ==================== 
To execute xls on a single file(unit test) following command can be used.
# java -jar saxon-he-12.5.jar -xsl:shortname.xsl -s:CryIfDemo.epc -o:output.epc

