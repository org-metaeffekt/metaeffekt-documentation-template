<?xml version='1.0' encoding='ASCII'?>
<xsl:stylesheet exclude-result-prefixes="ditaarch opentopic e" version="2.0" xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/" xmlns:e="com.acme" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:opentopic="http://www.idiominc.com/opentopic" xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!--
        Customizations of the numbering by adding numbering to the chapters and removing the prefix form the ToC.
        Also we make sure, that sections do not get a number prefix in the title element.

        Reference:
        - http://docs.easydita.com/DITA_Open_Toolkit_Customization/000001DITA_Open_Toolkit_PDF_Output_Customization/000008How_To_Number_Chapters_and_Sections

    -->

    <!-- define the depth of the numbering -->
    <xsl:variable name="e:number-levels" select="(true(), true(), true(), true())" />

    <!--
        Define the actual numbering of different document sections.

        The elements matched by this templates are '<title>'-elements.

        Additive to the stylesheets originally defined in:
            DITA_OT_HOME/plugins/org.dita.pdf2/xsl/fo/commons.xsl
    -->
    <xsl:template match="*" mode="getTitle">
        <!-- Get the topic, which is parent of this title element -->
        <xsl:variable name="topic" select="ancestor-or-self::*[contains(@class, ' topic/topic ')][1]" />
        <!-- Get the ID of the parent topic. -->
        <xsl:variable name="id" select="$topic/@id" />
        <!-- Find the parent topic in the map. -->
        <xsl:variable name="mapTopics" select="key('map-id', $id)" />
        <!-- Find out, if we are in a region, which should have no numbering -->
        <xsl:variable name="blacklistCount" select="count(ancestor-or-self::*[contains(@class, ' topic/section ')])" />

        <!-- only do numbering, if we are not in a blacklisted region (e.g. in a section) -->
        <xsl:if test="$blacklistCount = 0">
            <fo:inline>
                <xsl:for-each select="$mapTopics[1]">
                    <xsl:variable name="depth" select="count(ancestor-or-self::*[contains(@class, ' map/topicref')])" />
                    <xsl:choose>
                        <xsl:when test="parent::opentopic:map and contains(@class, ' bookmap/bookmap ')" />
                        <xsl:when test="ancestor-or-self::*[contains(@class, ' bookmap/frontmatter ') or contains(@class, ' bookmap/backmatter ')]" />
                        <xsl:when test="ancestor-or-self::*[contains(@class, ' bookmap/appendix ')] and $e:number-levels[$depth]">
                            <xsl:number count="*[contains(@class, ' map/topicref ')] [ancestor-or-self::*[contains(@class, ' bookmap/appendix ')]] " format="A.1.1" level="multiple" />
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:when test="$e:number-levels[$depth]">
                            <xsl:number count="*[contains(@class, ' map/topicref ')] [not(ancestor-or-self::*[contains(@class, ' bookmap/frontmatter ')])]" format="1.1.1" level="multiple" />
                            <xsl:text> </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </fo:inline>
        </xsl:if>

        <xsl:apply-templates />
    </xsl:template>

    <!--
        Get rid of the prefix in the ToC, since we prefix the actual headings/titles.

        Originally defined in:
        DITA_OT_HOME/plugins/org.dita.pdf2/xsl/fo/toc.xsl
    -->
    <xsl:template match="*[contains(@class, ' bookmap/chapter ')] |
        *[contains(@class, ' bookmap/bookmap ')]/opentopic:map/
        *[contains(@class, ' map/topicref ')]" mode="tocPrefix">
    </xsl:template>

</xsl:stylesheet>