<#--
This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->

<#-- Data prepared by the mantle.party.PartyServices.get#PartyBadgeInfo service -->

<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Helvetica, sans-serif" font-size="10pt">
    <fo:layout-master-set>
        <!-- page width and height for ISO/IEC 7810 ID-1: 3.370x2.125in -->
        <fo:simple-page-master master-name="label-medium" page-width="3.370in" page-height="2.125in" margin="0">
            <fo:region-body margin="0"/>
        </fo:simple-page-master>
    </fo:layout-master-set>

        <fo:page-sequence master-reference="label-medium">
            <fo:flow flow-name="xsl-region-body">
                <#if faceImageLocation?has_content>
                    <fo:block-container absolute-position="absolute" top="0" left="0" width="1.125in">
                        <fo:block text-align="center" vertical-align="top">
                            <fo:external-graphic src="${faceImageLocation}" content-width="1.125in" content-height="scale-to-fit" scaling="uniform"/>
                        </fo:block>
                    </fo:block-container>
                </#if>
                <#if logoImageLocation?has_content>
                    <fo:block-container absolute-position="absolute" top="0" left="1.25" width="1in">
                        <fo:block text-align="center" vertical-align="top">
                            <fo:external-graphic src="${logoImageLocation}" content-width="1in" content-height="scale-to-fit" scaling="uniform"/>
                        </fo:block>
                    </fo:block-container>
                </#if>
                <#if partyBadge.partyId?has_content>
                    <fo:block-container absolute-position="absolute" top="0.2in" left="2.35in" width="1in">
                        <fo:block text-align="left" font-size="8pt">${Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(partyBadge.partyId, true)}</fo:block>
                    </fo:block-container>
                </#if>
                <#if person?has_content>
                    <fo:block-container absolute-position="absolute" top="0.75in" left="1.25in" width="2in">
                        <fo:block text-align="left" font-size="14pt">${person.lastName!''},</fo:block>
                        <fo:block text-align="left" font-size="14pt">${person.firstName!''}</fo:block>
                    </fo:block-container>
                </#if>

                <fo:block-container absolute-position="absolute" top="1.5in" left="1.25in" width="2in">
                    <fo:block text-align="center">
                        <fo:instream-foreign-object>
                            <barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns" message="${partyBadgeId}">
                                <barcode:code128>
                                    <barcode:height>0.5in</barcode:height>
                                    <barcode:module-width>0.3mm</barcode:module-width>
                                </barcode:code128>
                                <barcode:human-readable>
                                    <barcode:placement>bottom</barcode:placement>
                                    <barcode:font-name>Helvetica</barcode:font-name>
                                    <barcode:font-size>12pt</barcode:font-size>
                                    <barcode:display-start-stop>false</barcode:display-start-stop>
                                    <barcode:display-checksum>false</barcode:display-checksum>
                                </barcode:human-readable>
                            </barcode:barcode>
                        </fo:instream-foreign-object>
                    </fo:block>
                </fo:block-container>
            </fo:flow>
        </fo:page-sequence>
</fo:root>
