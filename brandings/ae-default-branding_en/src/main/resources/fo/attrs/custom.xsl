<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

    <!-- Entry point for the DITA OT Plugin, see included files for actual customizations. -->

    <xsl:variable name="page-margin-inside" select="'10mm'"/>
    <xsl:variable name="page-margin-outside" select="'10mm'"/>

    <xsl:attribute-set name="__body__footnote__separator">
        <xsl:attribute name="leader-pattern">rule</xsl:attribute>
        <xsl:attribute name="leader-length">40%</xsl:attribute>
        <xsl:attribute name="rule-thickness">0.5pt</xsl:attribute>
        <xsl:attribute name="rule-style">solid</xsl:attribute>
        <xsl:attribute name="color">rgb(235, 235, 235)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn">
        <xsl:attribute name="font-size">6pt</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn__id">
        <xsl:attribute name="font-style">italic</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn__callout">
        <xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
        <xsl:attribute name="baseline-shift">10%</xsl:attribute>
        <xsl:attribute name="font-size">90%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn__body" use-attribute-sets="base-font">
        <xsl:attribute name="provisional-distance-between-starts">2mm</xsl:attribute>
        <xsl:attribute name="provisional-label-separation">2mm</xsl:attribute>
        <xsl:attribute name="line-height">1.2</xsl:attribute>
        <xsl:attribute name="start-indent">2mm</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="font-size">8pt</xsl:attribute>
        <xsl:attribute name="text-decoration">no-underline no-overline</xsl:attribute>
    </xsl:attribute-set>

    <xsl:variable name="toc.text-indent" select="'0pt'"/>
    <xsl:variable name="toc.toc-indent" select="'0pt'"/>

    <xsl:include href="customizations/ca_chapterBorders.xsl" />
    <xsl:include href="customizations/ca_cover.xsl" />
    <xsl:include href="customizations/ca_footer.xsl" />
    <xsl:include href="customizations/ca_header.xsl" />
    <xsl:include href="customizations/ca_lists.xsl" />
    <xsl:include href="customizations/ca_lot-lof.xsl" />
    <xsl:include href="customizations/ca_note.xsl" />
    <xsl:include href="customizations/ca_overall.xsl" />
    <xsl:include href="customizations/ca_screen.xsl" />
    <xsl:include href="customizations/ca_table.xsl" />
    <xsl:include href="customizations/ca_toc.xsl" />

    <!-- introduce spacing between glossary terms -->
    <!-- FIXME: move to dedicated file; clarify responsibilities between plugin and branding  -->
    <xsl:attribute-set name="__glossary__def">
        <xsl:attribute name="margin-left"><xsl:value-of select="$side-col-width"/></xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
    </xsl:attribute-set>

    <!-- use latin numbers for List of Tables (LOT) and List of Figures (LOF) -->
    <xsl:attribute-set name="page-sequence.lot" use-attribute-sets="page-sequence.toc">
        <xsl:attribute name="format">1</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-sequence.lof" use-attribute-sets="page-sequence.toc">
        <xsl:attribute name="format">1</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-sequence.frontmatter">
      <xsl:attribute name="format">1</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__topic__content">
        <xsl:attribute name="last-line-end-indent">0pt</xsl:attribute>
        <xsl:attribute name="end-indent">0pt</xsl:attribute>
        <xsl:attribute name="text-indent">0pt</xsl:attribute>
        <xsl:attribute name="text-align">start</xsl:attribute>
        <xsl:attribute name="text-align-last">justify</xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/>
            <xsl:choose>
                <xsl:when test="$level = 1">12pt</xsl:when>
                <xsl:otherwise><xsl:value-of select="$default-font-size"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/>
            <xsl:choose>
                <xsl:when test="$level = 1">bold</xsl:when>
                <xsl:otherwise>normal</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <!-- TOC related attribute tuning -->
    <xsl:attribute-set name="__toc__header" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-after">14.8pt</xsl:attribute>
        <xsl:attribute name="font-size">16pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="padding-top">14.8pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__chapter__content" use-attribute-sets="__toc__topic__content">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="padding-top">20pt</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__appendix__content" use-attribute-sets="__toc__topic__content">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="padding-top">20pt</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__preface__content" use-attribute-sets="__toc__topic__content">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="padding-top">20pt</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__notices__content" use-attribute-sets="__toc__topic__content">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="padding-top">20pt</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__indent__booklist" use-attribute-sets="__toc__indent">
        <xsl:attribute name="start-indent">0</xsl:attribute>
        <xsl:attribute name="space-before">10pt</xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__indent__lot" use-attribute-sets="__toc__indent__booklist">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="padding-top">10mm</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="lines" use-attribute-sets="base-font">
        <xsl:attribute name="space-before">0.0em</xsl:attribute>
        <xsl:attribute name="space-after">0.0em</xsl:attribute>
        <xsl:attribute name="white-space-collapse">true</xsl:attribute>
        <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>
        <xsl:attribute name="font-size">100%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:variable name="page-margin-bottom">25mm</xsl:variable>

    <xsl:attribute-set name="region-after">
        <xsl:attribute name="extent">25mm</xsl:attribute>
        <xsl:attribute name="display-align">after</xsl:attribute>
        <xsl:attribute name="padding-bottom">4mm</xsl:attribute>

        <!-- Uncomment to visualize footer region
        <xsl:attribute name="background-color">#f0f0f0</xsl:attribute>
        -->
    </xsl:attribute-set>

    <xsl:attribute-set name="lq" use-attribute-sets="common.block">
        <xsl:attribute name="start-indent">2mm + from-parent(start-indent)</xsl:attribute>
        <xsl:attribute name="end-indent">2mm + from-parent(end-indent)</xsl:attribute>
        <xsl:attribute name="background-color">rgb(235, 235, 235)</xsl:attribute>
        <xsl:attribute name="padding">2mm</xsl:attribute>
        <xsl:attribute name="padding-top">2mm</xsl:attribute>
        <xsl:attribute name="padding-bottom">2mm</xsl:attribute>
   </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.topic.title" use-attribute-sets="base-font common.title">
        <xsl:attribute name="space-before">10pt</xsl:attribute>
        <xsl:attribute name="font-size">11pt</xsl:attribute>
        <xsl:attribute name="start-indent"><xsl:value-of select="$side-col-width"/></xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>


</xsl:stylesheet>
