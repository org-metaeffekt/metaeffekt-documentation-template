<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

    <!--
        Complementary attribute changes and definitions for the custom front page.
    -->

    <xsl:attribute-set name="__frontmatter">
        <xsl:attribute name="text-align">center</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__title" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">100mm</xsl:attribute>
        <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
        <xsl:attribute name="font-size">26pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="line-height">140%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__subtitle" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">20mm</xsl:attribute>
        <xsl:attribute name="font-size">18pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="line-height">140%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__coverImageContainer">
        <xsl:attribute name="text-align">center</xsl:attribute>
        <xsl:attribute name="vertical-align">middle</xsl:attribute>
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="padding">0mm</xsl:attribute>
        <xsl:attribute name="margin">0mm</xsl:attribute>
        <xsl:attribute name="top">-20mm</xsl:attribute>
        <xsl:attribute name="left">-10mm</xsl:attribute>
        <xsl:attribute name="line-height">0mm</xsl:attribute>
        <xsl:attribute name="height">297mm</xsl:attribute>
        <xsl:attribute name="width">210mm</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__coverImageGfx">
        <xsl:attribute name="padding">0mm</xsl:attribute>
        <xsl:attribute name="margin">0mm</xsl:attribute>
        <xsl:attribute name="top">0mm</xsl:attribute>
        <xsl:attribute name="left">0mm</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>
