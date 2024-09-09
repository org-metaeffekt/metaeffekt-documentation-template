<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

    <!--
        The default of the DITA OT PDF Plugin is to create horizontal lines for
        chapters, sub-chapters, topics, etc. This here gets rid of them.
    -->

    <!-- get rid of the chapter borders -->

    <xsl:attribute-set name="__chapter__frontmatter__name__container">
        <xsl:attribute name="border-before-style">none</xsl:attribute>
        <xsl:attribute name="border-after-style">none</xsl:attribute>
    </xsl:attribute-set>

    <!-- get rid of the topic borders -->

    <xsl:attribute-set name="topic.title" use-attribute-sets="common.title">
        <xsl:attribute name="border-after-width">0pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.title" use-attribute-sets="common.title">
        <xsl:attribute name="border-after-width">0pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.title" use-attribute-sets="common.title">
        <xsl:attribute name="border-after-width">0pt</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>