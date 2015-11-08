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

    <fo:page-sequence master-reference="letter-portrait">
        <fo:static-content flow-name="xsl-region-before">
            <#if fromPartyDetail?has_content><fo:block font-size="14pt" text-align="center">${(Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(fromPartyDetail.organizationName!"", true))!""}${(fromPartyDetail.firstName)!""} ${(fromPartyDetail.lastName)!""}</fo:block></#if>
            <fo:block font-size="12pt" text-align="center" margin-bottom="0.1in">Shipment Picklist</fo:block>
            <fo:block-container absolute-position="absolute" top="0in" right="0.5in" width="3in">
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
                <fo:block text-align="center">Picklist for Shipment #${shipmentId} -- <#if shipment.estimatedShipDate??>${ec.l10n.format(shipment.estimatedShipDate, dateFormat)} -- </#if>Printed ${ec.l10n.format(ec.user.nowTimestamp, dateTimeFormat)} -- Page <fo:page-number/></fo:block>
            </fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">
            <fo:table table-layout="fixed" margin-bottom="0.1in" width="7.5in">
                <fo:table-body><fo:table-row>
                    <fo:table-cell padding="3pt" width="2in">
                        <fo:block font-weight="bold">Shipment #</fo:block>
                        <fo:block>${shipmentId}</fo:block>
                        <#if originFacility?has_content>
                            <fo:block font-weight="bold">Origin Facility</fo:block>
                            <fo:block>${ec.resource.expand("FacilityNameTemplate", "", originFacility)}</fo:block>
                        </#if>
                        <#if destinationFacility?has_content>
                            <fo:block font-weight="bold">Destination Facility</fo:block>
                            <fo:block>${ec.resource.expand("FacilityNameTemplate", "", destinationFacility)}</fo:block>
                        </#if>
                    </fo:table-cell>
                    <fo:table-cell padding="3pt" width="1.5in">
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
                        <fo:block>${(Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(toPartyDetail.organizationName!"", true))!""} ${(toPartyDetail.firstName)!""} ${(toPartyDetail.lastName)!""}</fo:block>
                        <#if toContactInfo.postalAddress?has_content>
                            <fo:block font-size="8pt">${(toContactInfo.postalAddress.address1)!""}<#if toContactInfo.postalAddress.unitNumber?has_content> #${toContactInfo.postalAddress.unitNumber}</#if></fo:block>
                            <#if toContactInfo.postalAddress.address2?has_content><fo:block font-size="8pt">${toContactInfo.postalAddress.address2}</fo:block></#if>
                            <fo:block font-size="8pt">${toContactInfo.postalAddress.city!""}, ${(toContactInfo.postalAddressStateGeo.geoCodeAlpha2)!""} ${toContactInfo.postalAddress.postalCode!""}<#if toContactInfo.postalAddress.postalCodeExt?has_content>-${toContactInfo.postalAddress.postalCodeExt}</#if></fo:block>
                            <#if toContactInfo.postalAddress.countryGeoId?has_content><fo:block font-size="8pt">${toContactInfo.postalAddress.countryGeoId}</fo:block></#if>
                        </#if>
                        <#if toContactInfo.telecomNumber?has_content>
                            <fo:block font-size="8pt"><#if toContactInfo.telecomNumber.countryCode?has_content>${toContactInfo.telecomNumber.countryCode}-</#if><#if toContactInfo.telecomNumber.areaCode?has_content>${toContactInfo.telecomNumber.areaCode}-</#if>${toContactInfo.telecomNumber.contactNumber!""}</fo:block>
                        </#if>
                        <#if toContactInfo.emailAddress?has_content>
                            <fo:block font-size="8pt">${toContactInfo.emailAddress}</fo:block>
                        </#if>
                    </fo:table-cell>
                </fo:table-row></fo:table-body>
            </fo:table>

            <#if reservedLocationInfoList?has_content>
                <@locationInfoTable reservedLocationInfoList "By Location - Reserved"/>
            </#if>
            <#if otherLocationInfoList?has_content>
                <@locationInfoTable otherLocationInfoList "By Location - Other/Alternate"/>
            </#if>
            <#if productInfoList?has_content>
                <fo:table table-layout="fixed" width="7.5in" border-bottom="solid black" margin-top="10pt">
                    <fo:table-header font-size="9pt" font-weight="bold" border-bottom="solid black">
                        <fo:table-cell width="2in" padding="${cellPadding}"><fo:block text-align="left">By Product</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Area</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Aisle</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Sec</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Level</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Pos</fo:block></fo:table-cell>

                        <fo:table-cell width="1.5in" padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Bin</fo:block></fo:table-cell>
                        <fo:table-cell width="1in" padding="${cellPadding}"><fo:block text-align="right">Quantity</fo:block></fo:table-cell>
                    </fo:table-header>
                    <fo:table-body>
                    <#list productInfoList as productInfo>
                        <fo:table-row font-size="9pt" border-top="solid black">
                            <fo:table-cell padding="${cellPadding}" number-columns-spanned="5"><fo:block text-align="center">
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
                            <fo:table-cell padding="${cellPadding}" number-columns-spanned="3"><fo:block text-align="left">${ec.resource.expand("ProductNameTemplate", "", productInfo)}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${productInfo.quantity}</fo:block></fo:table-cell>
                        </fo:table-row>
                        <#if productInfo.reservedLocationInfoList?has_content><#list productInfo.reservedLocationInfoList as locationInfo>
                            <fo:table-row font-size="9pt">
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${locationInfo.description!"No Location"}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.areaId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.aisleId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.sectionId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.levelId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.positionId!" "}</fo:block></fo:table-cell>

                                <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                            </fo:table-row>
                            <#list locationInfo.quantityByBin.keySet() as binLocationNumber>
                                <fo:table-row font-size="9pt">
                                    <fo:table-cell padding="${cellPadding}" number-columns-spanned="7"><fo:block> </fo:block></fo:table-cell>
                                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${binLocationNumber!" "}</fo:block></fo:table-cell>
                                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${locationInfo.quantityByBin.get(binLocationNumber!)}</fo:block></fo:table-cell>
                                </fo:table-row>
                            </#list>
                        </#list></#if>
                        <#if productInfo.otherLocationInfoList?has_content><#list productInfo.otherLocationInfoList as locationInfo>
                            <fo:table-row font-size="9pt" border-top="thin solid black">
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${locationInfo.description!"No Location"}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.areaId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.aisleId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.sectionId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.levelId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.positionId!" "}</fo:block></fo:table-cell>

                                <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                            </fo:table-row>
                            <#list locationInfo.quantityByBin.keySet() as binLocationNumber>
                                <fo:table-row font-size="9pt">
                                    <fo:table-cell padding="${cellPadding}" number-columns-spanned="7"><fo:block> </fo:block></fo:table-cell>
                                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${binLocationNumber!" "}</fo:block></fo:table-cell>
                                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${locationInfo.quantityByBin.get(binLocationNumber!)}</fo:block></fo:table-cell>
                                </fo:table-row>
                            </#list>
                        </#list></#if>
                    </#list>
                    </fo:table-body>
                </fo:table>
            </#if>
        </fo:flow>
    </fo:page-sequence>
</fo:root>

<#macro locationInfoTable locationInfoList titleString>
<fo:table table-layout="fixed" width="7.5in" border-bottom="solid black">
    <fo:table-header font-size="9pt" font-weight="bold" border-bottom="solid black">
        <fo:table-cell width="2in" padding="${cellPadding}"><fo:block text-align="left">${titleString}</fo:block></fo:table-cell>
        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Area</fo:block></fo:table-cell>
        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Aisle</fo:block></fo:table-cell>
        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Sec</fo:block></fo:table-cell>
        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Level</fo:block></fo:table-cell>
        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Pos</fo:block></fo:table-cell>

        <fo:table-cell width="1.5in" padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Bin</fo:block></fo:table-cell>
        <fo:table-cell width="1in" padding="${cellPadding}"><fo:block text-align="right">Quantity</fo:block></fo:table-cell>
    </fo:table-header>
    <fo:table-body>
    <#list locationInfoList as locationInfo>
        <fo:table-row font-size="9pt" border-top="solid black">
            <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${locationInfo.description!"No Location"}</fo:block></fo:table-cell>
            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.areaId!" "}</fo:block></fo:table-cell>
            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.aisleId!" "}</fo:block></fo:table-cell>
            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.sectionId!" "}</fo:block></fo:table-cell>
            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.levelId!" "}</fo:block></fo:table-cell>
            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.positionId!" "}</fo:block></fo:table-cell>

            <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
            <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
            <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
        </fo:table-row>
        <#list locationInfo.productInfoList as productInfo>
            <fo:table-row font-size="9pt">
                <fo:table-cell padding="${cellPadding}" number-columns-spanned="5"><fo:block text-align="center">
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
                <fo:table-cell padding="${cellPadding}" number-columns-spanned="4"><fo:block text-align="left">${ec.resource.expand("ProductNameTemplate", "", productInfo)}</fo:block></fo:table-cell>
            </fo:table-row>
            <#list productInfo.quantityByBin.keySet() as binLocationNumber>
                <fo:table-row font-size="9pt">
                    <fo:table-cell padding="${cellPadding}" number-columns-spanned="7"><fo:block> </fo:block></fo:table-cell>
                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${binLocationNumber!" "}</fo:block></fo:table-cell>
                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${productInfo.quantityByBin.get(binLocationNumber!)}</fo:block></fo:table-cell>
                </fo:table-row>
            </#list>
        </#list>
    </#list>
    </fo:table-body>
</fo:table>
</#macro>
