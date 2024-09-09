<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="metaeffekt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:metaeffekt="org.metaeffekt"
                version="2.0">

    <!--
        This customization here overrides the template, which creates the default FO layout masters. Overriding the
        template was required due to a small glitch in the simple-page-master of the 'toc-last' simple-page-master,
        which prevented the headers and footers to show up on pages within a 'toc-sequence' (LoF, LoT and ToC). This
        applied to the first page of a LoT, LoF and ToC where the page was on an even page number.

        The customization was introduced for the DITA OT 2.1.0, but this might be fixed in future DITA OT releases.
    -->

    <xsl:template name="createDefaultLayoutMasters">
        <fo:layout-master-set>
            <!-- Frontmatter simple masters -->
            <fo:simple-page-master master-name="front-matter-first" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body__frontmatter.odd"/>
                <fo:region-after region-name="odd-frontmatter-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <fo:simple-page-master master-name="front-matter-last" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body__frontmatter.even"/>
                <fo:region-before  region-name="last-frontmatter-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="last-frontmatter-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <xsl:if test="$mirror-page-margins">
                <fo:simple-page-master master-name="front-matter-even" xsl:use-attribute-sets="simple-page-master">
                    <fo:region-body xsl:use-attribute-sets="region-body__frontmatter.even"/>
                    <fo:region-before region-name="even-frontmatter-header" xsl:use-attribute-sets="region-before"/>
                    <fo:region-after region-name="even-frontmatter-footer" xsl:use-attribute-sets="region-after"/>
                </fo:simple-page-master>
            </xsl:if>

            <fo:simple-page-master master-name="front-matter-odd" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body__frontmatter.odd"/>
                <fo:region-before region-name="odd-frontmatter-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="odd-frontmatter-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <!-- Backcover simple masters -->
            <xsl:if test="$generate-back-cover">
                <!--fo:simple-page-master master-name="back-cover-first" xsl:use-attribute-sets="simple-page-master">
                  <fo:region-body xsl:use-attribute-sets="region-body__backcover.odd"/>
                </fo:simple-page-master-->

                <xsl:if test="$mirror-page-margins">
                    <fo:simple-page-master master-name="back-cover-even" xsl:use-attribute-sets="simple-page-master">
                        <fo:region-body xsl:use-attribute-sets="region-body__backcover.even"/>
                        <fo:region-before region-name="even-backcover-header" xsl:use-attribute-sets="region-before"/>
                        <fo:region-after region-name="even-backcover-footer" xsl:use-attribute-sets="region-after"/>
                    </fo:simple-page-master>
                </xsl:if>

                <fo:simple-page-master master-name="back-cover-odd" xsl:use-attribute-sets="simple-page-master">
                    <fo:region-body xsl:use-attribute-sets="region-body__backcover.odd"/>
                    <fo:region-before region-name="odd-backcover-header" xsl:use-attribute-sets="region-before"/>
                    <fo:region-after region-name="odd-backcover-footer" xsl:use-attribute-sets="region-after"/>
                </fo:simple-page-master>

                <fo:simple-page-master master-name="back-cover-last" xsl:use-attribute-sets="simple-page-master">
                    <fo:region-body xsl:use-attribute-sets="region-body__backcover.even"/>
                    <fo:region-before region-name="last-backcover-header" xsl:use-attribute-sets="region-before"/>
                    <fo:region-after region-name="last-backcover-footer" xsl:use-attribute-sets="region-after"/>
                </fo:simple-page-master>
            </xsl:if>

            <!--TOC simple masters-->
            <xsl:if test="$mirror-page-margins">
                <fo:simple-page-master master-name="toc-even" xsl:use-attribute-sets="simple-page-master">
                    <fo:region-body xsl:use-attribute-sets="region-body.even"/>
                    <fo:region-before region-name="even-toc-header" xsl:use-attribute-sets="region-before"/>
                    <fo:region-after region-name="even-toc-footer" xsl:use-attribute-sets="region-after"/>
                </fo:simple-page-master>
            </xsl:if>

            <fo:simple-page-master master-name="toc-odd" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body.odd"/>
                <fo:region-before region-name="odd-toc-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="odd-toc-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <!--
                Changed the string even to odd in all elements, since the "even" regions are not
                created, when the page margins are not mirrored
            -->
            <fo:simple-page-master master-name="toc-last" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body.odd"/>
                <fo:region-before region-name="odd-toc-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="odd-toc-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <fo:simple-page-master master-name="toc-first" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body.odd"/>
                <fo:region-before region-name="odd-toc-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="odd-toc-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <!--BODY simple masters-->
            <fo:simple-page-master master-name="body-first" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body.odd"/>
                <fo:region-before region-name="first-body-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="first-body-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <xsl:if test="$mirror-page-margins">
                <fo:simple-page-master master-name="body-even" xsl:use-attribute-sets="simple-page-master">
                    <fo:region-body xsl:use-attribute-sets="region-body.even"/>
                    <fo:region-before region-name="even-body-header" xsl:use-attribute-sets="region-before"/>
                    <fo:region-after region-name="even-body-footer" xsl:use-attribute-sets="region-after"/>
                </fo:simple-page-master>
            </xsl:if>

            <fo:simple-page-master master-name="body-odd" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body.odd"/>
                <fo:region-before region-name="odd-body-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="odd-body-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <fo:simple-page-master master-name="body-last" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body.even"/>
                <fo:region-before region-name="last-body-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="last-body-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <!--INDEX simple masters-->
            <fo:simple-page-master master-name="index-first" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body__index.odd"/>
                <fo:region-before region-name="odd-index-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="odd-index-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <xsl:if test="$mirror-page-margins">
                <fo:simple-page-master master-name="index-even" xsl:use-attribute-sets="simple-page-master">
                    <fo:region-body xsl:use-attribute-sets="region-body__index.even"/>
                    <fo:region-before region-name="even-index-header" xsl:use-attribute-sets="region-before"/>
                    <fo:region-after region-name="even-index-footer" xsl:use-attribute-sets="region-after"/>
                </fo:simple-page-master>
            </xsl:if>

            <fo:simple-page-master master-name="index-odd" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body__index.odd"/>
                <fo:region-before region-name="odd-index-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="odd-index-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <!--GLOSSARY simple masters-->
            <fo:simple-page-master master-name="glossary-first" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body.odd"/>
                <fo:region-before region-name="odd-glossary-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="odd-glossary-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <xsl:if test="$mirror-page-margins">
                <fo:simple-page-master master-name="glossary-even" xsl:use-attribute-sets="simple-page-master">
                    <fo:region-body xsl:use-attribute-sets="region-body.even"/>
                    <fo:region-before region-name="even-glossary-header" xsl:use-attribute-sets="region-before"/>
                    <fo:region-after region-name="even-glossary-footer" xsl:use-attribute-sets="region-after"/>
                </fo:simple-page-master>
            </xsl:if>

            <fo:simple-page-master master-name="glossary-odd" xsl:use-attribute-sets="simple-page-master">
                <fo:region-body xsl:use-attribute-sets="region-body.odd"/>
                <fo:region-before region-name="odd-glossary-header" xsl:use-attribute-sets="region-before"/>
                <fo:region-after region-name="odd-glossary-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>


            <!--Sequences-->
            <xsl:call-template name="generate-page-sequence-master">
                <xsl:with-param name="master-name" select="'toc-sequence'"/>
                <xsl:with-param name="master-reference" select="'toc'"/>
            </xsl:call-template>
            <xsl:call-template name="generate-page-sequence-master">
                <xsl:with-param name="master-name" select="'body-sequence'"/>
                <xsl:with-param name="master-reference" select="'body'"/>
            </xsl:call-template>
            <xsl:call-template name="generate-page-sequence-master">
                <xsl:with-param name="master-name" select="'ditamap-body-sequence'"/>
                <xsl:with-param name="master-reference" select="'body'"/>
                <xsl:with-param name="first" select="false()"/>
                <xsl:with-param name="last" select="false()"/>
            </xsl:call-template>
            <xsl:call-template name="generate-page-sequence-master">
                <xsl:with-param name="master-name" select="'index-sequence'"/>
                <xsl:with-param name="master-reference" select="'index'"/>
                <xsl:with-param name="last" select="false()"/>
            </xsl:call-template>
            <xsl:call-template name="generate-page-sequence-master">
                <xsl:with-param name="master-name" select="'front-matter'"/>
                <xsl:with-param name="master-reference" select="'front-matter'"/>
            </xsl:call-template>
            <xsl:if test="$generate-back-cover">
                <xsl:call-template name="generate-page-sequence-master">
                    <xsl:with-param name="master-name" select="'back-cover'"/>
                    <xsl:with-param name="master-reference" select="'back-cover'"/>
                    <xsl:with-param name="first" select="false()"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="generate-page-sequence-master">
                <xsl:with-param name="master-name" select="'glossary-sequence'"/>
                <xsl:with-param name="master-reference" select="'glossary'"/>
                <xsl:with-param name="last" select="false()"/>
            </xsl:call-template>
        </fo:layout-master-set>
    </xsl:template>

</xsl:stylesheet>