<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="metaeffekt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:metaeffekt="org.metaeffekt"
                version="2.0">

    <!--
        Implement the custom footer for all instances.
    -->

    <!-- the actual footer content -->

    <xsl:template name="genericCustomFooter">
        <!-- Product Name 
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
        <fo:leader leader-pattern="space"/>
        -->
        <!-- Document Category 
        <xsl:choose>
            <xsl:when test="$map/bookmeta/*[contains(@class,' topic/category ')][1]">
                <xsl:value-of select="$map/bookmeta/*[contains(@class,' topic/category ')][1]"/>
            </xsl:when>
        </xsl:choose>
        <fo:leader leader-pattern="space"/>
        -->

        <!-- Page number -->
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Custom Footer Page Number'"/>
            <xsl:with-param name="params">
                <pagenum>
                    Page <fo:page-number/> of <fo:page-number-citation ref-id="ae-last-page-marker" />
                </pagenum>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- normal page -->

    <xsl:template name="insertBodyFirstFooter">
        <fo:static-content flow-name="first-body-footer">
            <fo:block xsl:use-attribute-sets="__body__first__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyLastFooter">
        <fo:static-content flow-name="last-body-footer">
            <fo:block xsl:use-attribute-sets="__body__last__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyOddFooter">
        <fo:static-content flow-name="odd-body-footer">
            <fo:block xsl:use-attribute-sets="__body__odd__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyEvenFooter">
        <fo:static-content flow-name="even-body-footer">
            <fo:block xsl:use-attribute-sets="__body__even__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- TOC -->

    <xsl:template name="insertTocOddFooter">
        <fo:static-content flow-name="odd-toc-footer">
            <fo:block xsl:use-attribute-sets="__toc__odd__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocEvenFooter">
        <fo:static-content flow-name="even-toc-footer">
            <fo:block xsl:use-attribute-sets="__toc__even__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- Index -->

    <xsl:template name="insertIndexOddFooter">
        <fo:static-content flow-name="odd-index-footer">
            <fo:block xsl:use-attribute-sets="__index__odd__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertIndexEvenFooter">
        <fo:static-content flow-name="even-index-footer">
            <fo:block xsl:use-attribute-sets="__index__even__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- Preface -->

    <xsl:template name="insertPrefaceOddFooter">
        <fo:static-content flow-name="odd-body-footer">
            <fo:block xsl:use-attribute-sets="__body__odd__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceEvenFooter">
        <fo:static-content flow-name="even-body-footer">
            <fo:block xsl:use-attribute-sets="__body__even__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceFirstFooter">
        <fo:static-content flow-name="first-body-footer">
            <fo:block xsl:use-attribute-sets="__body__first__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceLastFooter">
        <fo:static-content flow-name="last-body-footer">
            <fo:block xsl:use-attribute-sets="__body__first__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- Front Matter -->

    <xsl:template name="insertFrontMatterOddFooter">
        <fo:static-content flow-name="odd-frontmatter-footer">
            <fo:block xsl:use-attribute-sets="__body__odd__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertFrontMatterEvenFooter">
        <fo:static-content flow-name="even-frontmatter-footer">
            <fo:block xsl:use-attribute-sets="__body__even__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertFrontMatterLastFooter">
        <fo:static-content flow-name="last-frontmatter-footer">
            <fo:block xsl:use-attribute-sets="__body__last__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- Glossary -->

    <xsl:template name="insertGlossaryOddFooter">
        <fo:static-content flow-name="odd-glossary-footer">
            <fo:block xsl:use-attribute-sets="__glossary__odd__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryEvenFooter">
        <fo:static-content flow-name="even-glossary-footer">
            <fo:block xsl:use-attribute-sets="__glossary__even__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- Back Cover -->

    <xsl:template name="insertBackCoverOddFooter">
        <fo:static-content flow-name="odd-backcover-footer">
            <fo:block xsl:use-attribute-sets="__body__odd__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBackCoverEvenFooter">
        <fo:static-content flow-name="even-backcover-footer">
            <fo:block xsl:use-attribute-sets="__body__even__footer">
                <xsl:call-template name="genericCustomFooter" />
            </fo:block>
        </fo:static-content>
    </xsl:template>
    
</xsl:stylesheet>