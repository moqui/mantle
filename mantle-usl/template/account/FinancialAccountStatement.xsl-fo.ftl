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

<#-- See the mantle.account.FinancialAccountServices.get#StatementPrintInfo service for data preparation -->

<#assign cellPadding = "1pt">
<#assign tableFontSize = tableFontSize!"9pt">
<#assign dateTimeFormat = dateTimeFormat!"dd MMM yyyy HH:mm">
<#assign dateFormat = dateFormat!"dd MMM yyyy">

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
        <fo:static-content flow-name="xsl-region-after" font-size="8pt">
            <fo:block border-top="thin solid black">
                <fo:block text-align="center">Account ${financialAccount.finAccountCode!financialAccount.finAccountId} -- <#if fromDate?exists>${ec.l10n.format(fromDate, dateFormat)} to <#else>All through </#if><#if thruDate?exists>${ec.l10n.format(thruDate, dateFormat)}<#else>${ec.l10n.format(ec.user.nowTimestamp, dateFormat)}</#if> -- Page <fo:page-number/></fo:block>
            </fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">

            <fo:block font-size="14pt" text-align="center" margin-bottom="0">${Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(organizationDetail.organizationName!"", false)}</fo:block>
            <fo:block font-size="13pt" text-align="center" margin-bottom="0.1in">Account Statement</fo:block>

            <fo:table table-layout="fixed" width="7.5in"><fo:table-body><fo:table-row font-size="10pt">
                <fo:table-cell padding="0.05in" width="3in">
                    <fo:block text-align="left">${Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(ownerDetail.organizationName!"", false)}${ownerDetail.firstName!""} ${ownerDetail.lastName!""}</fo:block>
                </fo:table-cell>
                <fo:table-cell padding="0.05in" width="2in">
                    <fo:block text-align="left" font-weight="bold">Account</fo:block>
                    <fo:block text-align="left">${financialAccount.finAccountCode!financialAccount.finAccountId}</fo:block>
                    <fo:block text-align="left" font-weight="bold">From</fo:block>
                    <fo:block text-align="left"><#if fromDate?exists>${ec.l10n.format(fromDate, dateFormat)}<#else>N/A</#if></fo:block>
                    <fo:block text-align="left" font-weight="bold">Through</fo:block>
                    <fo:block text-align="left"><#if thruDate?exists>${ec.l10n.format(thruDate, dateFormat)}<#else>${ec.l10n.format(ec.user.nowTimestamp, dateFormat)}</#if></fo:block>
                </fo:table-cell>
                <fo:table-cell padding="0.05in" width="2in">
                    <fo:block text-align="left" font-weight="bold">Begining Balance</fo:block>
                    <fo:block text-align="left">${ec.l10n.formatCurrency(beginningBalance, financialAccount.currencyUomId, 2)}</fo:block>
                    <fo:block text-align="left" font-weight="bold">Ending Balance</fo:block>
                    <fo:block text-align="left">${ec.l10n.formatCurrency(endingBalance, financialAccount.currencyUomId, 2)}</fo:block>
                </fo:table-cell>
            </fo:table-row></fo:table-body></fo:table>

            <#if financialAccountTransList?has_content>
            <fo:table table-layout="fixed" width="100%">
                <fo:table-header font-size="9pt" font-weight="bold" border-bottom="solid black">
                    <fo:table-cell width="0.6in" padding="${cellPadding}"><fo:block text-align="left">TX</fo:block></fo:table-cell>
                    <fo:table-cell width="0.8in" padding="${cellPadding}"><fo:block text-align="left">Date</fo:block></fo:table-cell>
                    <fo:table-cell width="1.0in" padding="${cellPadding}"><fo:block text-align="left">Reason</fo:block></fo:table-cell>
                    <fo:table-cell width="2.2in" padding="${cellPadding}"><fo:block text-align="left">Comments</fo:block></fo:table-cell>
                    <fo:table-cell width="1.0in" padding="${cellPadding}"><fo:block text-align="right">Amount</fo:block></fo:table-cell>
                    <fo:table-cell width="1.4in" padding="${cellPadding}"><fo:block text-align="right">Balance</fo:block></fo:table-cell>
                </fo:table-header>
                <fo:table-body>
                    <#list financialAccountTransList as trans>
                        <fo:table-row font-size="${tableFontSize}" border-bottom="thin solid black">
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${trans.finAccountTransId}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${ec.l10n.format(trans.transactionDate, dateFormat)}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${trans["FinancialAccountTransReason#moqui.basic.Enumeration"].description}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${trans.comments}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="right" font-family="Courier, monospace">${ec.l10n.formatCurrency(trans.amount, financialAccount.currencyUomId, 2)}<#if (trans.amount >= 0)>&#8199;</#if></fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="right" font-family="Courier, monospace">${ec.l10n.formatCurrency(trans.postBalance, financialAccount.currencyUomId, 2)}<#if (trans.postBalance >= 0)>&#8199;</#if></fo:block></fo:table-cell>
                        </fo:table-row>
                    </#list>
                </fo:table-body>
            </fo:table>
            </#if>
        </fo:flow>
    </fo:page-sequence>
</fo:root>
