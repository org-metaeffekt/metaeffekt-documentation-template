<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

    <!--
        Complementary attribute definitions for the footer customization.
    -->

    <xsl:attribute-set name="odd__footer" use-attribute-sets="common.border__top">
        <xsl:attribute name="border-before-color">#bbb</xsl:attribute>
        <xsl:attribute name="border-before-style">none</xsl:attribute>
        
        <xsl:attribute name="text-align">center</xsl:attribute>
        <xsl:attribute name="text-align-last">center</xsl:attribute>
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">9pt</xsl:attribute>
        <xsl:attribute name="font-weight">regular</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">15pt</xsl:attribute>
        <xsl:attribute name="margin-top">0pt</xsl:attribute>
        <xsl:attribute name="margin-left">
            <xsl:value-of select="$page-margins"/>
        </xsl:attribute>
        <xsl:attribute name="margin-right">
            <xsl:value-of select="$page-margins"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="even__footer" use-attribute-sets="odd__footer" />

    <xsl:attribute-set name="first__footer" use-attribute-sets="odd__footer" />

    <xsl:attribute-set name="__body__last__footer" use-attribute-sets="odd__footer" />

</xsl:stylesheet>
