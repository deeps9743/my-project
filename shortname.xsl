<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ns="http://autosar.org/schema/r4.0" exclude-result-prefixes="ns">
    <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
    
    <!-- Template to handle the root element -->
    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes">&lt;?xml version="1.0" encoding="UTF-8" standalone="no"?&gt;&#10;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Identity template to copy all nodes by default -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Template to handle specific case for SHORT-NAME elements -->
    <xsl:template match="ns:ECUC-CONTAINER-VALUE[parent::ns:SUB-CONTAINERS[parent::ns:ECUC-CONTAINER-VALUE[ns:DEFINITION-REF[@DEST='ECUC-CHOICE-CONTAINER-DEF']]]]/ns:SHORT-NAME">
        <!-- Define a variable for the parent SHORT-NAME -->
        <xsl:variable name="parentShortName" select="../ancestor::ns:ECUC-CONTAINER-VALUE[1]/ns:SHORT-NAME"/>

        <!-- Define a variable for the current SHORT-NAME -->
        <xsl:variable name="childShortName" select="."/>

        <!-- Define a variable for the last token in the child's DEFINITION-REF -->
        <xsl:variable name="childDefRefLastToken" select="tokenize(../ns:DEFINITION-REF, '/')[last()]"/>
        
        <!-- Check the conditions: parentShortName and childShortName comparison -->
        <xsl:choose>
            <xsl:when test="$parentShortName != $childShortName and $childShortName = $childDefRefLastToken">
                 <!-- Modify the SHORT-NAME to parentShortName -->
                <xsl:element name="SHORT-NAME" namespace="http://autosar.org/schema/r4.0">
                    <xsl:value-of select="$parentShortName"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- Output unchanged if conditions are not met -->
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
