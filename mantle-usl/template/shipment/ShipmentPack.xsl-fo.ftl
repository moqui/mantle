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

<#-- See the mantle.shipment.ShipmentServices.get#ShipmentPickPackInfo service for data preparation -->

<#assign cellPadding = "1pt">
<#assign dateFormat = dateFormat!"dd MMM yyyy">
<#assign dateTimeFormat = dateTimeFormat!"yyyy-MM-dd HH:mm">

<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Helvetica, sans-serif" font-size="10pt">
    <fo:layout-master-set>
        <fo:simple-page-master master-name="letter-portrait" page-width="8.5in" page-height="11in"
                               margin-top="0.5in" margin-bottom="0.5in" margin-left="0.5in" margin-right="0.5in">
            <fo:region-body margin-top="0.5in" margin-bottom="0.6in"/>
            <fo:region-before extent="0.5in"/>
            <fo:region-after extent="0.5in"/>
        </fo:simple-page-master>
    </fo:layout-master-set>

    <@shipmentPackPageSequence context/>
</fo:root>

<#macro shipmentPackPageSequence shipmentInfo>
    <#assign shipment = shipmentInfo.shipment!>
    <#assign shipmentId = (shipment.shipmentId)!>
    <#assign fromPartyDetail = shipmentInfo.fromPartyDetail!>
    <#assign fromContactInfo = shipmentInfo.fromContactInfo!>
    <#assign toPartyDetail = shipmentInfo.toPartyDetail!>
    <#assign toContactInfo = shipmentInfo.toContactInfo!>
    <#assign productInfoList = shipmentInfo.productInfoList!>

    <fo:page-sequence master-reference="letter-portrait" initial-page-number="1" force-page-count="no-force">
        <fo:static-content flow-name="xsl-region-before">
            <#if fromPartyDetail?has_content><fo:block font-size="14pt" text-align="center">${(Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(fromPartyDetail.organizationName!"", true))!""}${(fromPartyDetail.firstName)!""} ${(fromPartyDetail.lastName)!""}</fo:block></#if>
            <fo:block font-size="12pt" text-align="center" margin-bottom="0.1in">Shipment Pack Sheet</fo:block>
            <#if shipment.binLocationNumber?has_content>
                <fo:block-container absolute-position="absolute" top="0in" left="0in" width="0.6in">
                    <fo:block text-align="center" font-size="20pt" border="solid black" padding-top="2pt" font-weight="bold" font-family="Courier, monospace">${shipment.binLocationNumber}</fo:block>
                </fo:block-container>
            </#if>
            <fo:block-container absolute-position="absolute" top="0.1in" right="0.1in" width="3in">
                <fo:block text-align="right">
                    <fo:instream-foreign-object>
                        <barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns" message="${shipmentId}">
                            <barcode:code128>
                                <barcode:height>0.4in</barcode:height>
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
        </fo:static-content>
        <fo:static-content flow-name="xsl-region-after" font-size="8pt">
            <fo:block border-top="thin solid black">
                <#-- not displaying address, not needed in general:
                <fo:block text-align="center">
                <#if fromContactInfo.postalAddress?has_content>
                ${(fromContactInfo.postalAddress.address1)!""}<#if fromContactInfo.postalAddress.unitNumber?has_content> #${fromContactInfo.postalAddress.unitNumber}</#if><#if fromContactInfo.postalAddress.address2?has_content>, ${fromContactInfo.postalAddress.address2}</#if>, ${fromContactInfo.postalAddress.city!""}, ${(fromContactInfo.postalAddressStateGeo.geoCodeAlpha2)!""} ${fromContactInfo.postalAddress.postalCode!""}<#if fromContactInfo.postalAddress.postalCodeExt?has_content>-${fromContactInfo.postalAddress.postalCodeExt}</#if><#if fromContactInfo.postalAddress.countryGeoId?has_content>, ${fromContactInfo.postalAddress.countryGeoId}</#if>
                </#if>
                <#if fromContactInfo.telecomNumber?has_content>
                    -- <#if fromContactInfo.telecomNumber.countryCode?has_content>${fromContactInfo.telecomNumber.countryCode}-</#if><#if fromContactInfo.telecomNumber.areaCode?has_content>${fromContactInfo.telecomNumber.areaCode}-</#if>${fromContactInfo.telecomNumber.contactNumber!""}
                </#if>
                <#if fromContactInfo.emailAddress?has_content> -- ${fromContactInfo.emailAddress}</#if>
                </fo:block>
                -->
                <fo:block text-align="center">Pack Sheet for Shipment #${shipmentId} -- <#if shipment.estimatedShipDate??>${ec.l10n.format(shipment.estimatedShipDate, dateFormat)} -- </#if>Printed ${ec.l10n.format(ec.user.nowTimestamp, dateTimeFormat)} -- Page <fo:page-number/></fo:block>
            </fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">
            <fo:table table-layout="fixed" margin-bottom="0.1in" width="7.5in">
                <fo:table-body><fo:table-row>
                    <fo:table-cell padding="3pt" width="1.5in">
                        <fo:block font-weight="bold">Shipment #</fo:block>
                        <fo:block>${shipmentId}</fo:block>
                        <#if shipment.estimatedReadyDate?exists>
                            <fo:block font-weight="bold">Est. Ready</fo:block>
                            <fo:block>${ec.l10n.format(shipment.estimatedReadyDate, dateTimeFormat)}</fo:block>
                        </#if>
                        <#if shipment.estimatedShipDate?exists>
                            <fo:block font-weight="bold">Est. Ship</fo:block>
                            <fo:block>${ec.l10n.format(shipment.estimatedShipDate, dateTimeFormat)}</fo:block>
                        </#if>
                        <#if shipment.estimatedArrivalDate?exists>
                            <fo:block font-weight="bold">Est. Arrival</fo:block>
                            <fo:block>${ec.l10n.format(shipment.estimatedArrivalDate, dateTimeFormat)}</fo:block>
                        </#if>
                    </fo:table-cell>
                    <fo:table-cell padding="3pt" width="3in">
                        <fo:block font-weight="bold">From</fo:block>
                        <fo:block>${(Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(fromPartyDetail.organizationName!"", true))!""} ${(fromPartyDetail.firstName)!""} ${(fromPartyDetail.lastName)!""}</fo:block>
                        <#if fromContactInfo.postalAddress?has_content>
                            <fo:block>${(fromContactInfo.postalAddress.address1)!""}<#if fromContactInfo.postalAddress.unitNumber?has_content> #${fromContactInfo.postalAddress.unitNumber}</#if></fo:block>
                            <#if fromContactInfo.postalAddress.address2?has_content><fo:block>${fromContactInfo.postalAddress.address2}</fo:block></#if>
                            <fo:block>${fromContactInfo.postalAddress.city!""}, ${(fromContactInfo.postalAddressStateGeo.geoCodeAlpha2)!""} ${fromContactInfo.postalAddress.postalCode!""}<#if fromContactInfo.postalAddress.postalCodeExt?has_content>-${fromContactInfo.postalAddress.postalCodeExt}</#if></fo:block>
                            <#if fromContactInfo.postalAddress.countryGeoId?has_content><fo:block>${fromContactInfo.postalAddress.countryGeoId}</fo:block></#if>
                        </#if>
                        <#if fromContactInfo.telecomNumber?has_content>
                            <fo:block><#if fromContactInfo.telecomNumber.countryCode?has_content>${fromContactInfo.telecomNumber.countryCode}-</#if><#if fromContactInfo.telecomNumber.areaCode?has_content>${fromContactInfo.telecomNumber.areaCode}-</#if>${fromContactInfo.telecomNumber.contactNumber!""}</fo:block>
                        </#if>
                        <#if fromContactInfo.emailAddress?has_content>
                            <fo:block>${fromContactInfo.emailAddress}</fo:block>
                        </#if>
                    </fo:table-cell>
                    <fo:table-cell padding="3pt" width="3in">
                        <fo:block font-weight="bold">To</fo:block>
                        <fo:block>${(Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(toPartyDetail.organizationName!"", true))!""} ${(toPartyDetail.firstName)!""} ${(toPartyDetail.lastName)!""}</fo:block>
                        <#if toContactInfo.postalAddress?has_content>
                            <fo:block>${(toContactInfo.postalAddress.address1)!""}<#if toContactInfo.postalAddress.unitNumber?has_content> #${toContactInfo.postalAddress.unitNumber}</#if></fo:block>
                            <#if toContactInfo.postalAddress.address2?has_content><fo:block>${toContactInfo.postalAddress.address2}</fo:block></#if>
                            <fo:block>${toContactInfo.postalAddress.city!""}, ${(toContactInfo.postalAddressStateGeo.geoCodeAlpha2)!""} ${toContactInfo.postalAddress.postalCode!""}<#if toContactInfo.postalAddress.postalCodeExt?has_content>-${toContactInfo.postalAddress.postalCodeExt}</#if></fo:block>
                            <#if toContactInfo.postalAddress.countryGeoId?has_content><fo:block>${toContactInfo.postalAddress.countryGeoId}</fo:block></#if>
                        </#if>
                        <#if toContactInfo.telecomNumber?has_content>
                            <fo:block><#if toContactInfo.telecomNumber.countryCode?has_content>${toContactInfo.telecomNumber.countryCode}-</#if><#if toContactInfo.telecomNumber.areaCode?has_content>${toContactInfo.telecomNumber.areaCode}-</#if>${toContactInfo.telecomNumber.contactNumber!""}</fo:block>
                        </#if>
                        <#if toContactInfo.emailAddress?has_content>
                            <fo:block>${toContactInfo.emailAddress}</fo:block>
                        </#if>
                    </fo:table-cell>
                </fo:table-row></fo:table-body>
            </fo:table>

            <#if productInfoList?has_content>
                <fo:table table-layout="fixed" width="7.5in" border-bottom="solid black" margin-top="10pt">
                    <fo:table-header font-size="9pt" font-weight="bold" border-bottom="solid black">
                        <fo:table-cell width="3.5in" padding="${cellPadding}"><fo:block text-align="left">ID Barcode</fo:block></fo:table-cell>
                        <fo:table-cell width="3in" padding="${cellPadding}"><fo:block text-align="left">Product</fo:block></fo:table-cell>
                        <fo:table-cell width="1in" padding="${cellPadding}"><fo:block text-align="center">Quantity</fo:block></fo:table-cell>
                    </fo:table-header>
                    <fo:table-body>
                    <#list productInfoList as productInfo>
                        <fo:table-row font-size="9pt" border-top="solid black">
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">
                                <fo:instream-foreign-object>
                                    <barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns" message="${productInfo.productId}">
                                        <barcode:code128>
                                            <barcode:height>0.4in</barcode:height>
                                            <barcode:module-width>0.25mm</barcode:module-width>
                                        </barcode:code128>
                                        <barcode:human-readable>
                                            <barcode:placement>bottom</barcode:placement>
                                            <barcode:font-name>Helvetica</barcode:font-name>
                                            <barcode:font-size>7pt</barcode:font-size>
                                            <barcode:display-start-stop>false</barcode:display-start-stop>
                                            <barcode:display-checksum>false</barcode:display-checksum>
                                        </barcode:human-readable>
                                    </barcode:barcode>
                                </fo:instream-foreign-object>
                            </fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${ec.resource.expand("ProductNameTemplate", "", productInfo)}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${productInfo.quantity}</fo:block></fo:table-cell>
                        </fo:table-row>
                    </#list>
                    </fo:table-body>
                </fo:table>
            </#if>
        </fo:flow>
    </fo:page-sequence>
</#macro>
