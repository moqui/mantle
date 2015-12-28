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

<#-- Printed check layout for 3 part business check on 8.5x11" paper: 8.5x3.5" check on top with 3.5" and 4" stubs -->
<#-- Adequate for QuickBooks/etc preprinted checks -->

<#--
    Data prepared by the mantle.account.PaymentServices.get#PaymentCheckInfo service, such as:

    <set field="paymentIdList" from="paymentIds instanceof List ? paymentIds : paymentIds.split(',') as List"/>
    <service-call name="mantle.account.PaymentServices.get#PaymentCheckInfo" out-map="context"
            in-map="[paymentIdList:paymentIdList]"/>
-->

<#assign checkPosition = checkPosition!"top">
<#assign topHeight = topHeight!"3.5in">
<#assign middleHeight = middleHeight!"3.5in">
<#assign bottomHeight = bottomHeight!"4in">

<#assign separatePayToLine = separatePayToLine!true>
<#assign checkNumber = checkNumber!false>
<#assign secondarySignature = secondarySignature!false>

<#assign stubLines = true>

<#assign fontSize = "10pt">
<#assign amountCharacters = 15><#-- enought for up to 999 million: 999,999,999.99 -->
<#assign amountWordsCharacters = 84>
<#assign dateFormat = dateFormat!"dd MMM yyyy">

<#assign cellPadding = "1pt">
<#assign tableFontSize = tableFontSize!"9pt">
<#assign detailTableFontSize = detailTableFontSize!"8pt">

<#macro checkBody paymentInfo>
    <#-- Check number, if populated -->
    <#if checkNumber && paymentInfo.payment.paymentRefNum?has_content>
    <fo:block-container absolute-position="absolute" top="0.25in" right="0.5in" width="1.5in">
        <fo:block text-align="right" font-size="12pt" font-family="Courier, monospace">${paymentInfo.payment.paymentRefNum!" "}</fo:block>
    </fo:block-container>
    </#if>

    <#-- Date -->
    <fo:block-container absolute-position="absolute" top="0.8in" right="0.6in" width="1in">
        <fo:block text-align="right">${ec.l10n.format(paymentInfo.payment.effectiveDate, dateFormat)}</fo:block>
    </fo:block-container>

    <#-- Pay to line -->
    <#if separatePayToLine>
    <fo:block-container absolute-position="absolute" top="1.3in" left="1.1in">
        <fo:block text-align="left">${Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(paymentInfo.toPartyDetail.organizationName!"", false)}${paymentInfo.toPartyDetail.firstName!} ${paymentInfo.toPartyDetail.lastName!}</fo:block>
    </fo:block-container>
    </#if>

    <#-- Amount - numeric -->
    <fo:block-container absolute-position="absolute" top="1.3in" right="0.35in" width="1.3in">
    <#-- 1.2in seems to fit 14 Courier characters at 10pt just right -->
        <#assign amountString = ec.l10n.format(paymentInfo.payment.amount, "#,##0.00")>
        <#assign asterisks = amountCharacters - amountString?length>
        <fo:block text-align="right" font-family="Courier, monospace"><#list 1..asterisks as i>*</#list>${amountString}</fo:block>
    </fo:block-container>

    <#-- Amount - text -->
    <fo:block-container absolute-position="absolute" top="1.65in" left="0.3in">
        <#assign asterisks = amountWordsCharacters - paymentInfo.amountWords?length>
        <fo:block text-align="left" font-family="Courier, monospace">${paymentInfo.amountWords}<#list 1..asterisks as i>*</#list></fo:block>
    </fo:block-container>

    <#-- Mailing name and address -->
    <fo:block-container absolute-position="absolute" top="2in" left="1.1in" width="4in" height="0.8in">
        <#assign contactInfo = paymentInfo.toBillingContactInfo>
        <#if (contactInfo.postalAddress.toName)?has_content || (contactInfo.postalAddress.attnName)?has_content>
            <#if (contactInfo.postalAddress.toName)?has_content><fo:block text-align="left">${contactInfo.postalAddress.toName}</fo:block></#if>
            <#if (contactInfo.postalAddress.attnName)?has_content><fo:block text-align="left">Attn: ${contactInfo.postalAddress.attnName}</fo:block></#if>
        <#else>
            <fo:block text-align="left">${Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(paymentInfo.toPartyDetail.organizationName!"", false)}${paymentInfo.toPartyDetail.firstName!} ${paymentInfo.toPartyDetail.lastName!}</fo:block>
        </#if>
        <#if (contactInfo.postalAddress.address1)?has_content><fo:block text-align="left">${contactInfo.postalAddress.address1}<#if (contactInfo.postalAddress.unitNumber)?has_content> #${contactInfo.postalAddress.unitNumber}</#if></fo:block></#if>
        <#if (contactInfo.postalAddress.address2)?has_content><fo:block text-align="left">${contactInfo.postalAddress.address2}</fo:block></#if>
        <#if (contactInfo.postalAddress)?has_content><fo:block text-align="left">${contactInfo.postalAddress.city!}<#if (contactInfo.postalAddressStateGeo.geoCodeAlpha2)?has_content>, ${contactInfo.postalAddressStateGeo.geoCodeAlpha2} </#if>${contactInfo.postalAddress.postalCode!}<#if (contactInfo.postalAddress.postalCodeExt)?has_content>-${contactInfo.postalAddress.postalCodeExt}</#if><#if (contactInfo.postalAddressCountryGeo.geoCodeAlpha3)?has_content> ${contactInfo.postalAddressCountryGeo.geoCodeAlpha3}</#if></fo:block></#if>
        <#if (contactInfo.telecomNumber)?has_content><fo:block text-align="left"><#if (contactInfo.telecomNumber.countryCode)?has_content>${contactInfo.telecomNumber.countryCode}-</#if><#if (contactInfo.telecomNumber.areaCode)?has_content>${contactInfo.telecomNumber.areaCode}-</#if>${contactInfo.telecomNumber.contactNumber!}</fo:block></#if>
    <#-- <#if (contactInfo.emailAddress)?has_content><fo:block text-align="left">${contactInfo.emailAddress}</fo:block></#if> -->
    </fo:block-container>

    <#-- Memo -->
    <fo:block-container absolute-position="absolute" top="2.75in" left="0.8in" width="4in">
        <fo:block text-align="left">${paymentInfo.payment.memo!" "}</fo:block>
    </fo:block-container>

    <#-- Primary Signature image -->
    <#if paymentInfo.paymentSignaturePrimaryLocation?has_content>
    <fo:block-container absolute-position="absolute" bottom="0.65in" right="1in" width="2in" height="0.4in">
        <fo:block text-align="center" vertical-align="bottom">
            <fo:external-graphic src="${paymentInfo.paymentSignaturePrimaryLocation}" content-height="0.33in" content-width="scale-to-fit" scaling="uniform"/>
        </fo:block>
    </fo:block-container>
    </#if>
    <#-- Secondary Signature image -->
    <#if secondarySignature && paymentInfo.paymentSignatureSecondaryLocation?has_content>
    <fo:block-container absolute-position="absolute" bottom="0.3in" right="1in" width="2in" height="0.4in">
        <fo:block text-align="center" vertical-align="bottom">
            <fo:external-graphic src="${paymentInfo.paymentSignatureSecondaryLocation}" content-height="0.33in" content-width="scale-to-fit" scaling="uniform"/>
        </fo:block>
    </fo:block-container>
    </#if>
</#macro>
<#macro stubBody paymentInfo>
<fo:block margin="0.3in" overflow="hidden">
    <fo:block text-align="left" margin-bottom="0.1in">${Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(paymentInfo.fromPartyDetail.organizationName!"", false)}${paymentInfo.fromPartyDetail.firstName!} ${paymentInfo.fromPartyDetail.lastName!} - Payment #${paymentInfo.payment.paymentId}<#if paymentInfo.payment.paymentRefNum?has_content> - Check #${paymentInfo.payment.paymentRefNum}</#if></fo:block>

    <#if paymentInfo.invoiceList?has_content>
        <fo:table table-layout="fixed" width="7.5in">
            <fo:table-header font-size="9pt" font-weight="bold" border-bottom="solid black">
                <fo:table-cell width="1.3in" padding="${cellPadding}"><fo:block text-align="left">Our Ref #</fo:block></fo:table-cell>
                <fo:table-cell width="1.3in" padding="${cellPadding}"><fo:block text-align="left">Your Ref #</fo:block></fo:table-cell>
                <fo:table-cell width="1.7in" padding="${cellPadding}"><fo:block text-align="left">Invoice Date</fo:block></fo:table-cell>
                <fo:table-cell width="1.6in" padding="${cellPadding}"><fo:block text-align="right">Invoice Amount</fo:block></fo:table-cell>
                <fo:table-cell width="1.6in" padding="${cellPadding}"><fo:block text-align="right">Amount Paid</fo:block></fo:table-cell>
            </fo:table-header>
            <fo:table-body>
                <#list paymentInfo.invoiceList as invoice>
                    <#assign invoiceTotals = ec.service.sync().name("mantle.account.InvoiceServices.get#InvoiceTotal").parameter("invoiceId", invoice.invoiceId).call()>
                    <fo:table-row font-size="${tableFontSize}" border-bottom="thin solid black">
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${invoice.invoiceId}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${invoice.referenceNumber!""}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${ec.l10n.format(invoice.invoiceDate, dateFormat)}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="right" font-family="Courier, monospace">${ec.l10n.formatCurrency(invoiceTotals.invoiceTotal, invoice.currencyUomId, 2)}</fo:block></fo:table-cell>
                        <fo:table-cell padding="${cellPadding}"><fo:block text-align="right" font-family="Courier, monospace">${ec.l10n.formatCurrency(invoice.amountApplied, invoice.currencyUomId, 2)}</fo:block></fo:table-cell>
                    </fo:table-row>
                </#list>
            </fo:table-body>
        </fo:table>
        <#if paymentInfo.invoiceList?size == 1>
            <#-- if there is just one invoice show its items; mainly for payroll checks but useful for others too -->
            <#assign invoice = paymentInfo.invoiceList[0]>
            <#assign invoiceItemList = ec.entity.find("mantle.account.invoice.InvoiceItem").condition("invoiceId", invoice.invoiceId).list()>
            <fo:table table-layout="fixed" width="7.5in">
                <fo:table-header font-size="9pt" font-weight="bold" border-bottom="solid black" border-top="solid black">
                    <fo:table-cell width="0.3in" padding="${cellPadding}"><fo:block text-align="left">Item</fo:block></fo:table-cell>
                    <fo:table-cell width="3.3in" padding="${cellPadding}"><fo:block text-align="left">Description</fo:block></fo:table-cell>
                    <fo:table-cell width="0.7in" padding="${cellPadding}"><fo:block text-align="right">Qty</fo:block></fo:table-cell>
                    <fo:table-cell width="1.6in" padding="${cellPadding}"><fo:block text-align="right">Amount</fo:block></fo:table-cell>
                    <fo:table-cell width="1.6in" padding="${cellPadding}"><fo:block text-align="right">Total</fo:block></fo:table-cell>
                </fo:table-header>
                <fo:table-body>
                    <#list invoiceItemList as invoiceItem>
                        <fo:table-row font-size="${tableFontSize}">
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${invoiceItem.invoiceItemSeqId}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${invoiceItem.description!""}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${invoiceItem.quantity!"1"}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="right" font-family="Courier, monospace">${ec.l10n.formatCurrency(invoiceItem.amount, invoice.currencyUomId, 3)}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="right" font-family="Courier, monospace">${ec.l10n.formatCurrency(((invoiceItem.quantity!1) * (invoiceItem.amount!0)), invoice.currencyUomId, 3)}</fo:block></fo:table-cell>
                        </fo:table-row>
                    </#list>
                </fo:table-body>
            </fo:table>
        </#if>
    </#if>

    <#if paymentInfo.financialAccountTrans??>
        <fo:table table-layout="fixed" width="7in">
            <fo:table-header font-size="9pt" font-weight="bold" border-bottom="solid black">
                <fo:table-cell width="1.6in" padding="${cellPadding}"><fo:block text-align="left">Account #</fo:block></fo:table-cell>
                <fo:table-cell width="1.6in" padding="${cellPadding}"><fo:block text-align="left">TX #</fo:block></fo:table-cell>
                <fo:table-cell width="1.6in" padding="${cellPadding}"><fo:block text-align="left">TX Date</fo:block></fo:table-cell>
                <fo:table-cell width="2in" padding="${cellPadding}"><fo:block text-align="right">TX Amount</fo:block></fo:table-cell>
            </fo:table-header>
            <fo:table-body>
                <fo:table-row font-size="${tableFontSize}" border-bottom="thin solid black">
                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${paymentInfo.financialAccount.finAccountCode!paymentInfo.financialAccount.finAccountId}</fo:block></fo:table-cell>
                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${paymentInfo.financialAccountTrans.finAccountTransId}</fo:block></fo:table-cell>
                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${ec.l10n.format(paymentInfo.financialAccountTrans.transactionDate, dateFormat)}</fo:block></fo:table-cell>
                    <fo:table-cell padding="${cellPadding}"><fo:block text-align="right" font-family="Courier, monospace">${ec.l10n.formatCurrency(paymentInfo.financialAccountTrans.amount, paymentInfo.financialAccount.currencyUomId, 2)}</fo:block></fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </#if>

</fo:block>
</#macro>

<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Helvetica, sans-serif" font-size="${fontSize}">
    <fo:layout-master-set>
        <fo:simple-page-master master-name="letter-portrait" page-width="8.5in" page-height="11in"
                               margin-top="0in" margin-bottom="0in" margin-left="0in" margin-right="0in">
            <fo:region-body margin-top="0in" margin-bottom="0in"/>
            <#-- <fo:region-before extent="1in"/><fo:region-after extent="0.5in"/> -->
        </fo:simple-page-master>
    </fo:layout-master-set>

    <#list paymentInfoList as paymentInfo>
        <fo:page-sequence master-reference="letter-portrait">
            <fo:flow flow-name="xsl-region-body">

                <#-- Top Area -->
                <fo:block-container absolute-position="absolute" top="0" left="0" width="8.5in" height="${topHeight}">
                    <#if checkPosition == "top"><@checkBody paymentInfo/><#else><@stubBody paymentInfo/></#if>
                </fo:block-container>

                <#-- Middle Area -->
                <fo:block-container absolute-position="absolute" top="3.5in" left="0" width="8.5in" height="${middleHeight}"<#if stubLines> border="thin solid black"</#if>>
                    <#if checkPosition == "middle"><@checkBody paymentInfo/><#else><@stubBody paymentInfo/></#if>
                </fo:block-container>

                <#-- Bottom Area -->
                <fo:block-container absolute-position="absolute" top="7in" left="0" width="8.5in" height="${bottomHeight}">
                    <#if checkPosition == "bottom"><@checkBody paymentInfo/><#else><@stubBody paymentInfo/></#if>
                </fo:block-container>
            </fo:flow>
        </fo:page-sequence>
    </#list>
</fo:root>
