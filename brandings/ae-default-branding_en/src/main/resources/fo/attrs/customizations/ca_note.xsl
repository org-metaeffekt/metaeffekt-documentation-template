<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

    <!--
        Complementary attribute definitions for the note element customization.
    -->

    <!--
        Add the horizontal lines before and after the note element.
    -->
    <xsl:attribute-set name="note__table" use-attribute-sets="common.block common.border__top common.border__bottom">
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
        <xsl:attribute name="start-indent">0pt</xsl:attribute>
        <xsl:attribute name="space-before">1cm</xsl:attribute>
        <xsl:attribute name="space-after">1cm</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note__image__column">
        <xsl:attribute name="column-number">1</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note__text__entry">
        <xsl:attribute name="start-indent">0pt</xsl:attribute>
        <xsl:attribute name="padding">6pt</xsl:attribute>
        <xsl:attribute name="padding-after">10pt</xsl:attribute>
        <xsl:attribute name="padding-before">10pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="metaeffekt__note__image__graphic">
        <xsl:attribute name="padding-before">10pt</xsl:attribute>
        <xsl:attribute name="padding-after">10pt</xsl:attribute>
        <xsl:attribute name="content-width">50%</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>