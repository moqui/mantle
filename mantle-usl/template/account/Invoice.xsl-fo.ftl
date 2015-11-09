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

<#-- See the mantle.account.InvoiceServices.get#InvoicePrintInfo service for data preparation -->

<#assign cellPadding = "1pt">
<#assign dateFormat = dateFormat!"dd MMM yyyy">

<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Helvetica, sans-serif" font-size="10pt">
    <fo:layout-master-set>
        <fo:simple-page-master master-name="letter-portrait" page-width="8.5in" page-height="11in"
                               margin-top="0.5in" margin-bottom="0.5in" margin-left="0.5in" margin-right="0.5in">
            <fo:region-body margin-top="0.5in" margin-bottom="0.6in"/>
            <fo:region-before extent="0.5in"/>
            <fo:region-after extent="0.5in"/>
        </fo:simple-page-master>
    </fo:layout-master-set>

    <fo:page-sequence master-reference="letter-portrait" id="mainSequence">
        <fo:static-content flow-name="xsl-region-before">
            <fo:block font-size="14pt" text-align="center">${(Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(fromParty.organizationName!"", true))!""}${(fromParty.firstName)!""} ${(fromParty.lastName)!""}</fo:block>
            <fo:block font-size="12pt" text-align="center" margin-bottom="0.1in">INVOICE</fo:block>
            <fo:block-container absolute-position="absolute" top="0.3in" right="0.5in" width="3in">
                <fo:block text-align="right">
                    <fo:instream-foreign-object>
                        <barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns" message="${invoiceId}">
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
                <fo:block text-align="center">
                <#if fromContactInfo.postalAddress?has_content>
                ${(fromContactInfo.postalAddress.address1)!""}<#if fromContactInfo.postalAddress.unitNumber?has_content> #${fromContactInfo.postalAddress.unitNumber}</#if><#if fromContactInfo.postalAddress.address2?has_content>, ${fromContactInfo.postalAddress.address2}</#if>, ${fromContactInfo.postalAddress.city!""}, ${(fromContactInfo.postalAddressStateGeo.geoCodeAlpha2)!""} ${fromContactInfo.postalAddress.postalCode!""}<#if fromContactInfo.postalAddress.postalCodeExt?has_content>-${fromContactInfo.postalAddress.postalCodeExt}</#if><#if fromContactInfo.postalAddress.countryGeoId?has_content>, ${fromContactInfo.postalAddress.countryGeoId}</#if>
                </#if>
                <#if fromContactInfo.telecomNumber?has_content>
                    -- <#if fromContactInfo.telecomNumber.countryCode?has_content>${fromContactInfo.telecomNumber.countryCode}-</#if><#if fromContactInfo.telecomNumber.areaCode?has_content>${fromContactInfo.telecomNumber.areaCode}-</#if>${fromContactInfo.telecomNumber.contactNumber!""}
                </#if>
                <#if fromContactInfo.emailAddress?has_content> -- ${fromContactInfo.emailAddress}</#if>
                </fo:block>
                <fo:block text-align="center">Invoice #${invoiceId} -- ${ec.l10n.format(invoice.invoiceDate, dateFormat)} -- Page <fo:page-number/> of <fo:page-number-citation-last ref-id="mainSequence"/></fo:block>
            </fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">
            <fo:table table-layout="fixed" margin-bottom="0.1in" width="7.5in">
                <fo:table-body><fo:table-row>
                    <fo:table-cell padding="3pt" width="1.75in">
                        <fo:block font-weight="bold">Invoice #</fo:block>
                        <fo:block>${invoiceId}</fo:block>
                        <fo:block font-weight="bold">Total</fo:block>
                        <fo:block>${ec.l10n.formatCurrency(invoiceTotal, invoice.currencyUomId, 2)} ${invoice.currencyUomId}</fo:block>
                    </fo:table-cell>
                    <fo:table-cell padding="3pt" width="1.75in">
                        <fo:block font-weight="bold">Date</fo:block>
                        <fo:block>${ec.l10n.format(invoice.invoiceDate, dateFormat)}</fo:block>
                        <#if invoice.dueDate?exists>
                            <fo:block font-weight="bold">Due</fo:block>
                            <fo:block>${ec.l10n.format(invoice.dueDate, dateFormat)}</fo:block>
                        </#if>
                        <#if settlementTerm?has_content>
                            <fo:block font-weight="bold">Term</fo:block>
                            <fo:block>${settlementTerm.description}</fo:block>
                        </#if>
                    </fo:table-cell>
                    <fo:table-cell padding="3pt" width="3in">
                        <#if toBillingRep?has_content><fo:block>Attention: ${(toBillingRep.organizationName)!""} ${(toBillingRep.firstName)!""} ${(toBillingRep.lastName)!""}</fo:block></#if>
                        <fo:block>${(Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(toParty.organizationName!"", true))!""} ${(toParty.firstName)!""} ${(toParty.lastName)!""}</fo:block>
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

            <fo:table table-layout="fixed" width="100%">
                <fo:table-header font-size="9pt" border-bottom="solid black">
                    <fo:table-cell width="0.3in" padding="${cellPadding}"><fo:block text-align="center">Item</fo:block></fo:table-cell>
                    <fo:table-cell width="1in" padding="${cellPadding}"><fo:block>Type</fo:block></fo:table-cell>
                    <fo:table-cell width="0.8in" padding="${cellPadding}"><fo:block>Date</fo:block></fo:table-cell>
                    <fo:table-cell width="2.8in" padding="${cellPadding}"><fo:block>Description</fo:block></fo:table-cell>
                    <fo:table-cell width="0.6in" padding="${cellPadding}"><fo:block text-align="center">Qty</fo:block></fo:table-cell>
                    <fo:table-cell width="0.9in" padding="${cellPadding}"><fo:block text-align="right">Amount</fo:block></fo:table-cell>
                    <fo:table-cell width="1in" padding="${cellPadding}"><fo:block text-align="right">Total</fo:block></fo:table-cell>
                </fo:table-header>
                <fo:table-body>
                <#list invoiceItemList as invoiceItem>
                    <#assign itemTypeEnum = invoiceItem.findRelatedOne("ItemType#moqui.basic.Enumeration", true, false)>
                    <#assign timeEntry = invoiceItem.findRelatedOne("mantle.work.time.TimeEntry", false, false)?if_exists>
                    <#assign rateTypeEnum = "">
                    <#assign workEffort = "">
                    <#if timeEntry?has_content>
                        <#assign rateTypeEnum = timeEntry.findRelatedOne("RateType#moqui.basic.Enumeration", true, false)?if_exists>
                        <#assign workEffort = timeEntry.findRelatedOne("mantle.work.effort.WorkEffort", false, false)?if_exists>
                    </#if>
                    <fo:table-row font-size="8pt" border-bottom="thin solid black">
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${invoiceItem.invoiceItemSeqId}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block>${(itemTypeEnum.description)!""}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block>${ec.l10n.format(invoiceItem.itemDate, dateFormat)}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}">
                            <fo:block>${Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(invoiceItem.description!"", true)}</fo:block>
                            <#if (timeEntry.workEffortId)?has_content><fo:block>Task: ${timeEntry.workEffortId} - ${workEffort.workEffortName!""}</fo:block></#if>
                            <#if rateTypeEnum?has_content><fo:block>Rate: ${rateTypeEnum.description}</fo:block></#if>
                            <#if timeEntry?has_content><fo:block>${ec.l10n.format(timeEntry.fromDate, "dd MMM yyyy hh:mm")} to ${ec.l10n.format(timeEntry.thruDate, "dd MMM yyyy hh:mm")}, Break ${timeEntry.breakHours!"0"}h</fo:block></#if>
                        </fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${invoiceItem.quantity!"1"}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${ec.l10n.formatCurrency(invoiceItem.amount!0, invoice.currencyUomId, 3)}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${ec.l10n.formatCurrency(((invoiceItem.quantity!1) * (invoiceItem.amount!0)), invoice.currencyUomId, 3)}</fo:block></fo:table-cell>
                    </fo:table-row>
                </#list>
                    <fo:table-row font-size="9pt" border-top="solid black">
                        <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block></fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">Total</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${ec.l10n.formatCurrency(invoiceTotal, invoice.currencyUomId, 2)}</fo:block></fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>

            <fo:table table-layout="fixed" width="100%">
                <fo:table-header font-size="9pt" border-bottom="solid black">
                    <fo:table-cell width="1.5in" padding="${cellPadding}"><fo:block>Type</fo:block></fo:table-cell>
                    <fo:table-cell width="0.8in" padding="${cellPadding}"><fo:block text-align="center">Qty</fo:block></fo:table-cell>
                    <fo:table-cell width="0.9in" padding="${cellPadding}"><fo:block text-align="right">Amount</fo:block></fo:table-cell>
                    <fo:table-cell width="1in" padding="${cellPadding}"><fo:block text-align="right">Total</fo:block></fo:table-cell>
                </fo:table-header>
                <fo:table-body>
                <#list itemTypeSummaryMapList as itemTypeSummaryMap>
                    <#assign itemTypeEnum = ec.entity.find("moqui.basic.Enumeration").condition("enumId", itemTypeSummaryMap.itemTypeEnumId).useCache(true).one()>
                    <fo:table-row font-size="8pt" border-bottom="thin solid black">
                        <fo:table-cell padding="${cellPadding}"><fo:block>${(itemTypeEnum.description)!""}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${itemTypeSummaryMap.quantity}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${ec.l10n.formatCurrency(itemTypeSummaryMap.amount, invoice.currencyUomId, 2)}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${ec.l10n.formatCurrency(itemTypeSummaryMap.total, invoice.currencyUomId, 2)}</fo:block></fo:table-cell>
                    </fo:table-row>
                </#list>
                </fo:table-body>
            </fo:table>

            <#if invoice.invoiceMessage?has_content><fo:block margin-top="0.2in">${invoice.invoiceMessage}</fo:block></#if>
        </fo:flow>
    </fo:page-sequence>
</fo:root>
