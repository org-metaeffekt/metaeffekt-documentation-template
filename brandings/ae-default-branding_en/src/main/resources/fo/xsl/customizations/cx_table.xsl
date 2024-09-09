<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="metaeffekt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:metaeffekt="org.metaeffekt"
                version="2.0">

    <!--
        Alternating colors for table rows.
    -->

    <xsl:template match="*[contains(@class, ' topic/tbody ')]/*[contains(@class, ' topic/row ')]">
        <fo:table-row xsl:use-attribute-sets="tbody.row">
            <xsl:choose>
                <xsl:when test="(count(preceding-sibling::*[contains(@class, ' topic/row ')]) mod 2) = 0">
                    <!-- even row, white -->
                    <xsl:attribute name="background-color">rgb(250, 250, 250)</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <!-- odd row, gray -->
                    <xsl:attribute name="background-color">rgb(235, 235, 235)</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:table-row>
    </xsl:template>

    <!--
        The following moves the title of the table under/after the table.

        Overrides:
            plugins/org.dita.pdf2/xsl/fo/tables.xsl
    -->

    <xsl:template match="*[contains(@class, ' topic/table ')]">
        <!-- FIXME, empty value -->
        <xsl:variable name="scale" as="xs:string?">
            <xsl:call-template name="getTableScale"/>
        </xsl:variable>

        <fo:block xsl:use-attribute-sets="table">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="not(@id)">
                <xsl:attribute name="id">
                    <xsl:call-template name="get-id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="exists($scale)">
                <xsl:attribute name="font-size" select="concat($scale, '%')"/>
            </xsl:if>
            <!-- BEGIN Modification -->
            <!--
                The following replaces the this line in the original:
                    <xsl:apply-templates/>
                This is required to re-order the table and the title.
            -->
            <xsl:apply-templates select="*[contains(@class, ' topic/tgroup ')]"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/title ') or contains(@class, ' topic/desc ')]"/>
            <!-- END Modification -->
        </fo:block>
    </xsl:template>

</xsl:stylesheet>