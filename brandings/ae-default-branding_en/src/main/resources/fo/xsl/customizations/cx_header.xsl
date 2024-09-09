<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="metaeffekt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:metaeffekt="org.metaeffekt"
                version="2.0">

    <!--
        Implement the custom header for all instances.
    -->

    <!-- generic -->

    <xsl:template name="genericCustomHeader">
        <fo:block-container xsl:use-attribute-sets="__watermarkImageContainer">
            <fo:block>
                <fo:external-graphic xsl:use-attribute-sets="__watermarkImageGfx" src="url(Customization/OpenTopic/common/artwork/watermark.svg)"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <!--
        Body
    -->

    <xsl:template name="insertBodyOddHeader">
        <fo:static-content flow-name="odd-body-header">
            <fo:block xsl:use-attribute-sets="__body__odd__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyEvenHeader">
        <fo:static-content flow-name="even-body-header">
            <fo:block xsl:use-attribute-sets="__body__even__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyFirstHeader">
        <fo:static-content flow-name="first-body-header">
            <fo:block xsl:use-attribute-sets="__body__first__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyLastHeader">
        <fo:static-content flow-name="last-body-header">
            <fo:block xsl:use-attribute-sets="__body__last__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- TOC -->

    <xsl:template name="insertTocOddHeader">
        <fo:static-content flow-name="odd-toc-header">
            <fo:block xsl:use-attribute-sets="__toc__odd__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocEvenHeader">
        <fo:static-content flow-name="even-toc-header">
            <fo:block xsl:use-attribute-sets="__toc__even__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- Index -->

    <xsl:template name="insertIndexOddHeader">
        <fo:static-content flow-name="odd-index-header">
            <fo:block xsl:use-attribute-sets="__index__odd__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertIndexEvenHeader">
        <fo:static-content flow-name="even-index-header">
            <fo:block xsl:use-attribute-sets="__index__even__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- Preface -->

    <xsl:template name="insertPrefaceOddHeader">
        <fo:static-content flow-name="odd-body-header">
            <fo:block xsl:use-attribute-sets="__body__odd__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceEvenHeader">
        <fo:static-content flow-name="even-body-header">
            <fo:block xsl:use-attribute-sets="__body__even__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceFirstHeader">
        <fo:static-content flow-name="first-body-header">
            <fo:block xsl:use-attribute-sets="__body__first__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceLastHeader">
        <fo:static-content flow-name="last-body-header">
            <fo:block xsl:use-attribute-sets="__body__last__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- Front Matter -->

    <xsl:template name="insertFrontMatterOddHeader">
        <fo:static-content flow-name="odd-frontmatter-header">
            <fo:block xsl:use-attribute-sets="__body__odd__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertFrontMatterEvenHeader">
        <fo:static-content flow-name="even-frontmatter-header">
            <fo:block xsl:use-attribute-sets="__body__even__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertFrontMatterLastHeader">
        <fo:static-content flow-name="last-frontmatter-header">
            <fo:block xsl:use-attribute-sets="__body__even__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- Glossary -->

    <xsl:template name="insertGlossaryOddHeader">
        <fo:static-content flow-name="odd-glossary-header">
            <fo:block xsl:use-attribute-sets="__glossary__odd__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryEvenHeader">
        <fo:static-content flow-name="even-glossary-header">
            <fo:block xsl:use-attribute-sets="__glossary__even__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <!-- BackCover -->

    <xsl:template name="insertBackCoverOddHeader">
        <fo:static-content flow-name="odd-backcover-header">
            <fo:block xsl:use-attribute-sets="__body__odd__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBackCoverEvenHeader">
        <fo:static-content flow-name="even-backcover-header">
            <fo:block xsl:use-attribute-sets="__body__even__header">
                <xsl:call-template name="genericCustomHeader" />
            </fo:block>
        </fo:static-content>
    </xsl:template>

</xsl:stylesheet>