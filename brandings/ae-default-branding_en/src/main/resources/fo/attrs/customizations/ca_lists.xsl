<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

    <!--
        Overrides:
            ./plugins/org.dita.pdf2/cfg/fo/attrs/lists-attr.xsl
    -->

    <!-- Adapt the spacing between list items. -->

    <xsl:variable name="metaeffekt.list.item-spacing">5pt</xsl:variable>

    <xsl:attribute-set name="ul.li">
        <xsl:attribute name="space-after"><xsl:value-of select="$metaeffekt.list.item-spacing"/></xsl:attribute>
        <xsl:attribute name="space-before"><xsl:value-of select="$metaeffekt.list.item-spacing"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="ol.li">
        <xsl:attribute name="space-after"><xsl:value-of select="$metaeffekt.list.item-spacing"/></xsl:attribute>
        <xsl:attribute name="space-before"><xsl:value-of select="$metaeffekt.list.item-spacing"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="sl.sli">
        <xsl:attribute name="space-after"><xsl:value-of select="$metaeffekt.list.item-spacing"/></xsl:attribute>
        <xsl:attribute name="space-before"><xsl:value-of select="$metaeffekt.list.item-spacing"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="ol.li__label__content">
        <xsl:attribute name="text-align">start</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
    </xsl:attribute-set>

    <!-- Adapt the space between the bullet points and the actual text.  -->

    <xsl:attribute-set name="ul" use-attribute-sets="common.block">
        <xsl:attribute name="provisional-distance-between-starts">3mm</xsl:attribute>
        <xsl:attribute name="provisional-label-separation">1mm</xsl:attribute>
        <!--        <xsl:attribute name="margin-left">-8pt</xsl:attribute>-->
    </xsl:attribute-set>

</xsl:stylesheet>