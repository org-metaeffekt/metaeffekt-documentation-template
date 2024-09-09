<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

    <!--
        Make chapters start on a new page.
    -->
    <xsl:attribute-set name="__force__page__count">
        <xsl:attribute name="force-page-count">no-force</xsl:attribute>
    </xsl:attribute-set>

    <!-- DIN/ISO A4 -->
    <xsl:variable name="page-width">210mm</xsl:variable>
    <xsl:variable name="page-height">297mm</xsl:variable>

    <!-- Reduce additional indentation for body text. -->
    <xsl:variable name="side-col-width">0em</xsl:variable>

    <xsl:variable name="default-font-size">10pt</xsl:variable>
    <xsl:variable name="default-line-height">12pt</xsl:variable>

    <!-- Overall font settings. -->
    <xsl:attribute-set name="__fo__root">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
        <xsl:attribute name="text-align">justify</xsl:attribute>
    </xsl:attribute-set>
    
    <!-- Reduce the font size of pre element content. The intention is to
         better harmonize the font sizes of helvetica and monospace in the
         normal text (pre, codeph) and to enable more characters in a
         codeblock line.
         
         The current setting allows 100 characters in a codeblock line in the
         rendered PDF.
         
         Background:
         - codeblock extends the pre attribute-set and is therefore covered implicitly
     -->
    <xsl:attribute-set name="pre" use-attribute-sets="base-font common.block">
        <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
        <xsl:attribute name="white-space-collapse">false</xsl:attribute>
        <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>
        <xsl:attribute name="font-family">monospace</xsl:attribute>
        <xsl:attribute name="line-height">120%</xsl:attribute>
        <xsl:attribute name="font-size">80%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="codeph">
        <xsl:attribute name="font-family">monospace</xsl:attribute>
        <xsl:attribute name="font-size">80%</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>
