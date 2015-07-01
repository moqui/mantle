<#--
This software is in the public domain under CC0 1.0 Universal.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->

<#-- See the mantle.account.InvoiceServices.get#InvoicePrintInfo service for data preparation -->

<#assign cellPadding = "1pt">
<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Helvetica, sans-serif" font-size="10pt">
    <fo:layout-master-set>
        <fo:simple-page-master master-name="letter-portrait" page-width="8.5in" page-height="11in"
                               margin-top="0.5in" margin-bottom="0.5in" margin-left="0.5in" margin-right="0.5in">
            <fo:region-body margin-top="0.4in" margin-bottom="0.6in"/>
            <fo:region-before extent="1in"/>
            <fo:region-after extent="0.5in"/>
        </fo:simple-page-master>
    </fo:layout-master-set>

    <fo:page-sequence master-reference="letter-portrait" id="mainSequence">
        <fo:static-content flow-name="xsl-region-before">
            <fo:block font-size="14pt" text-align="center">${(Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(firstPartInfo.vendorDetail.organizationName!"", true))!""}${(firstPartInfo.vendorDetail.firstName)!""} ${(firstPartInfo.vendorDetail.lastName)!""}</fo:block>
            <fo:block font-size="12pt" text-align="center" margin-bottom="0.1in">ORDER</fo:block>
            <fo:block text-align="right">
                <fo:instream-foreign-object>
                    <barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns" message="${orderId}">
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
        </fo:static-content>
        <fo:static-content flow-name="xsl-region-after" font-size="8pt">
            <fo:block border-top="thin solid black">
                <#-- TODO: show vendor's contact info (customer service or billing address, phone, email -->
                <fo:block text-align="center">Order #${orderId} -- <#if orderHeader.placedDate??>${ec.l10n.format(orderHeader.placedDate, "dd MMM yyyy")}<#else>Not yet placed</#if> -- Page <fo:page-number/></fo:block>
            </fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">
            <fo:table table-layout="fixed" margin-bottom="0.1in">
                <fo:table-body><fo:table-row>
                    <fo:table-cell padding="3pt">
                        <fo:block>Order #${orderId}</fo:block>
                        <fo:block>Date: <#if orderHeader.placedDate??>${ec.l10n.format(orderHeader.placedDate, "dd MMM yyyy")}<#else>Not yet placed</#if></fo:block>
                        <fo:block>Total: ${ec.l10n.formatCurrency(orderHeader.grandTotal, orderHeader.currencyUomId, 2)}</fo:block>
                    </fo:table-cell>
                </fo:table-row></fo:table-body>
            </fo:table>

            <#list orderPartInfoList as orderPartInfo>
                <#assign orderPart = orderPartInfo.orderPart>
                <#if orderPartInfo.isCustomerInternalOrg><#assign contactInfo = orderPartInfo.facilityContactInfo>
                    <#else><#assign contactInfo = orderPartInfo></#if>

                <fo:table table-layout="fixed" margin-bottom="0.1in">
                    <fo:table-body><fo:table-row>
                        <fo:table-cell padding="3pt">
                            <fo:block>Order Part #${orderPart.orderPartSeqId}</fo:block>
                            <fo:block>Part Total: ${ec.l10n.formatCurrency(orderPart.partTotal, orderHeader.currencyUomId, 2)}</fo:block>
                            <#if orderPartInfo.shipmentMethodEnum?has_content>
                                <fo:block>Ship By: ${orderPartInfo.shipmentMethodEnum.description}</fo:block></#if>
                            <fo:block>Ship Before: ${ec.l10n.format(orderPart.shipBeforeDate, "")}</fo:block>
                            <fo:block>Delivery Date: ${ec.l10n.format(orderPart.estimatedDeliveryDate, "")}</fo:block>
                            <#if orderPartInfo.facility?has_content>
                                <fo:block>To Facility: ${ec.resource.expand("FacilityNameTemplate", "", orderPartInfo.facility)}</fo:block></#if>
                        </fo:table-cell>
                        <fo:table-cell padding="3pt" font-size="10pt">
                            <fo:block>${(Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(orderPartInfo.customerDetail.organizationName!"", true))!""} ${(orderPartInfo.customerDetail.firstName)!""} ${(orderPartInfo.customerDetail.lastName)!""}</fo:block>
                            <#if contactInfo.postalAddress?has_content>
                                <fo:block>${(contactInfo.postalAddress.address1)!""}<#if contactInfo.postalAddress.unitNumber?has_content> #${contactInfo.postalAddress.unitNumber}</#if></fo:block>
                                <#if contactInfo.postalAddress.address2?has_content><fo:block font-size="8pt">${contactInfo.postalAddress.address2}</fo:block></#if>
                                <fo:block>${contactInfo.postalAddress.city!""}, ${(contactInfo.postalAddressStateGeo.geoCodeAlpha2)!""} ${contactInfo.postalAddress.postalCode!""}<#if contactInfo.postalAddress.postalCodeExt?has_content>-${contactInfo.postalAddress.postalCodeExt}</#if></fo:block>
                                <#if contactInfo.postalAddress.countryGeoId?has_content><fo:block font-size="8pt">${contactInfo.postalAddress.countryGeoId}</fo:block></#if>
                            </#if>
                            <#if contactInfo.telecomNumber?has_content>
                                <fo:block><#if contactInfo.telecomNumber.countryCode?has_content>${contactInfo.telecomNumber.countryCode}-</#if><#if contactInfo.telecomNumber.areaCode?has_content>${contactInfo.telecomNumber.areaCode}-</#if>${contactInfo.telecomNumber.contactNumber!""}</fo:block>
                            </#if>
                            <#if contactInfo.emailAddress?has_content>
                                <fo:block>${contactInfo.emailAddress}</fo:block>
                            </#if>
                        </fo:table-cell>
                    </fo:table-row></fo:table-body>
                </fo:table>

                <fo:table table-layout="fixed" width="100%">
                    <fo:table-header font-size="9pt" border-bottom="solid black">
                        <fo:table-cell width="0.3in" padding="${cellPadding}"><fo:block text-align="center">Item</fo:block></fo:table-cell>
                        <fo:table-cell width="1in" padding="${cellPadding}"><fo:block>Type</fo:block></fo:table-cell>
                        <fo:table-cell width="0.8in" padding="${cellPadding}"><fo:block>By Date</fo:block></fo:table-cell>
                        <fo:table-cell width="2.8in" padding="${cellPadding}"><fo:block>Description</fo:block></fo:table-cell>
                        <fo:table-cell width="0.6in" padding="${cellPadding}"><fo:block text-align="center">Qty</fo:block></fo:table-cell>
                        <fo:table-cell width="0.9in" padding="${cellPadding}"><fo:block text-align="right">Amount</fo:block></fo:table-cell>
                        <fo:table-cell width="1in" padding="${cellPadding}"><fo:block text-align="right">Total</fo:block></fo:table-cell>
                    </fo:table-header>
                    <fo:table-body>
                        <#list orderPartInfo.partOrderItemList as orderItem>
                            <#assign itemTypeEnum = orderItem.findRelatedOne("ItemType#moqui.basic.Enumeration", true, false)>
                            <#assign orderItemTotalOut = ec.service.sync().name("mantle.order.OrderServices.get#OrderItemTotal").parameter("orderItem", orderItem).call()>
                            <fo:table-row font-size="8pt" border-bottom="thin solid black">
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${orderItem.orderItemSeqId}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block>${(itemTypeEnum.description)!""}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block>${ec.l10n.format(orderItem.requiredByDate, "dd MMM yyyy")}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}">
                                    <fo:block>${orderItem.itemDescription!""}</fo:block>
                                    <#if orderItem.productId?has_content>
                                        <#assign product = ec.entity.find("mantle.product.Product").condition("productId", orderItem.productId).useCache(true).one()>
                                        <fo:block>${ec.resource.expand("ProductNameTemplate", "", product)}</fo:block>
                                    </#if>
                                </fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${orderItem.quantity!"1"}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${ec.l10n.formatCurrency(orderItem.unitAmount!0, orderHeader.currencyUomId, 3)}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${ec.l10n.formatCurrency(orderItemTotalOut.itemTotal, orderHeader.currencyUomId, 3)}</fo:block></fo:table-cell>
                            </fo:table-row>
                        </#list>
                        <fo:table-row font-size="9pt" border-top="solid black">
                            <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">Total</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${ec.l10n.formatCurrency(orderPart.partTotal, orderHeader.currencyUomId, 2)}</fo:block></fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>

                <#if orderPartInfo.orderPart.shippingInstructions?has_content>
                    <fo:block margin-top="0.2in" font-weight="bold">Shipping Instructions</fo:block>
                    <fo:block>${orderPartInfo.orderPart.shippingInstructions}</fo:block>
                </#if>
                <#if orderPartInfo.orderPart.giftMessage?has_content>
                    <fo:block margin-top="0.2in" font-weight="bold">Gift Message</fo:block>
                    <fo:block>${orderPartInfo.orderPart.giftMessage}</fo:block>
                </#if>

            </#list>
        </fo:flow>
    </fo:page-sequence>
</fo:root>
