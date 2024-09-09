<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="metaeffekt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:metaeffekt="org.metaeffekt"
                version="2.0">
    <!--
        Create the custom cover page.
    -->

    <xsl:template name="createFrontCoverContents">
        <!-- insert image into the cover -->
        <xsl:call-template name="metaeffekt:cover-image" />
        <!-- set the title 
        <fo:block xsl:use-attribute-sets="__frontmatter__title">
            <xsl:choose>
                <xsl:when test="$map/*[contains(@class,' topic/title ')][1]">
                    <xsl:apply-templates select="$map/*[contains(@class,' topic/title ')][1]"/>
                </xsl:when>
                <xsl:when test="$map//*[contains(@class,' bookmap/mainbooktitle ')][1]">
                    <xsl:apply-templates select="$map//*[contains(@class,' bookmap/mainbooktitle ')][1]"/>
                </xsl:when>
                <xsl:when test="//*[contains(@class, ' map/map ')]/@title">
                    <xsl:value-of select="//*[contains(@class, ' map/map ')]/@title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="/descendant::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
        -->
        <!-- set the subtitle -->
        <!--
        <xsl:apply-templates select="$map//*[contains(@class,' bookmap/booktitlealt ')]"/>
        <fo:block xsl:use-attribute-sets="__frontmatter__owner">
            <xsl:apply-templates select="$map//*[contains(@class,' bookmap/bookmeta ')]"/>
        </fo:block>
        <fo:block xsl:use-attribute-sets="__frontmatter__subtitle">
            <xsl:choose>
                <xsl:when test="$map/bookmeta/*[contains(@class,' topic/category ')][1]">
                    <xsl:value-of select="$map/bookmeta/*[contains(@class,' topic/category ')][1]"/>
                </xsl:when>
            </xsl:choose>
        </fo:block>
        -->

		<!--        
        <fo:block xsl:use-attribute-sets="__frontmatter__subtitle">
            <xsl:choose>
                <xsl:when test="$map/bookmeta/bookid/bookpartno">
                    <xsl:value-of select="$map/bookmeta/bookid/bookpartno[1]"/>
                </xsl:when>
            </xsl:choose>
        </fo:block>
        -->
    </xsl:template>

    <!--
        Resolve the path to the cover image from the variable definitions.
    -->
    <xsl:template name="metaeffekt:cover-image">
        <xsl:variable name="path">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'cover-image-path'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:apply-templates mode="placeCoverImage" select=".">
            <xsl:with-param name="href" select="concat($artworkPrefix, $path)" />
        </xsl:apply-templates>
    </xsl:template>

    <!--
        The actual FO block for the graphic.
    -->
    <xsl:template match="*" mode="placeCoverImage">
        <xsl:param name="href"/>
        <fo:block-container xsl:use-attribute-sets="__coverImageContainer">
            <fo:block>
                <fo:external-graphic xsl:use-attribute-sets="__coverImageGfx" src="url('{$href}')" />
            </fo:block>
        </fo:block-container>
    </xsl:template>

</xsl:stylesheet>