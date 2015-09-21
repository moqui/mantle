<!--
This software is in the public domain under CC0 1.0 Universal.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->

<!-- See the mantle.ledger.LedgerReportServices.run#CashFlowStatement service for data preparation -->

<#assign showDetail = (detail! == "true")>

<#macro showClass classInfo depth>
    <tr>
        <td style="padding-left: ${(depth-1) * 2}.3em;">${ec.l10n.localize(classInfo.className)}</td>
        <#list timePeriodIdList as timePeriodId>
            <#assign beginningClassBalance = (classInfo.balanceByTimePeriod[timePeriodId]!0) - (classInfo.postedByTimePeriod[timePeriodId]!0)>
            <td class="text-right">${ec.l10n.formatCurrency(classInfo.postedByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td>
            <td class="text-right">${ec.l10n.formatCurrency(beginningClassBalance, currencyUomId, 2)}</td>
            <td class="text-right">${ec.l10n.formatCurrency(classInfo.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td>
        </#list>
    </tr>
    <#list classInfo.glAccountInfoList! as glAccountInfo>
        <#if showDetail>
            <tr>
                <td style="padding-left: ${(depth-1) * 2 + 3}.3em;">${glAccountInfo.accountCode}: ${glAccountInfo.accountName}</td>
                <#list timePeriodIdList as timePeriodId>
                    <#assign beginningGlAccountBalance = (glAccountInfo.balanceByTimePeriod[timePeriodId]!0) - (glAccountInfo.postedByTimePeriod[timePeriodId]!0)>
                    <td class="text-right">${ec.l10n.formatCurrency(glAccountInfo.postedByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td>
                    <td class="text-right">${ec.l10n.formatCurrency(beginningGlAccountBalance, currencyUomId, 2)}</td>
                    <td class="text-right">${ec.l10n.formatCurrency(glAccountInfo.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td>
                </#list>
            </tr>
        <#else>
            <!-- ${glAccountInfo.accountCode}: ${glAccountInfo.accountName} ${glAccountInfo.balanceByTimePeriod} -->
        </#if>
    </#list>
    <#list classInfo.childClassInfoList as childClassInfo>
        <@showClass childClassInfo depth + 1/>
    </#list>
    <#if depth == 1>
        <tr class="text-info">
            <td><strong>${ec.l10n.localize(classInfo.className + " Total")}</strong></td>
            <#list timePeriodIdList as timePeriodId>
                <#assign beginningTotalBalance = (classInfo.totalBalanceByTimePeriod[timePeriodId]!0) - (classInfo.totalPostedByTimePeriod[timePeriodId]!0)>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(classInfo.totalPostedByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(beginningTotalBalance, currencyUomId, 2)}</strong></td>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(classInfo.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
            </#list>
        </tr>
    </#if>
</#macro>

<table class="table table-striped table-hover table-condensed">
    <thead>
        <tr>
            <th>${ec.l10n.localize("Cash Flow Statement")}</th>
            <#list timePeriodIdList as timePeriodId>
                <th class="text-right">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed}) Posted</th>
                <th class="text-right">Beginning</th>
                <th class="text-right">Ending</th>
            </#list>
        </tr>
    </thead>
    <tbody>
        <tr style="border-top: solid black;">
            <td><strong>${ec.l10n.localize("Operating Activities")}</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"> </td><td class="text-right"> </td><td class="text-right"> </td></#list>
        </tr>
        <tr class="text-success">
            <td><strong>${ec.l10n.localize("Net Income")}</strong></td>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(netIncomeMap[timePeriodId]!0, currencyUomId, 2)}</strong></td>
                <td class="text-right"><strong> </strong></td>
                <td class="text-right"><strong> </strong></td>
            </#list>
        </tr>
        <#if classInfoById.CONTRA_ASSET??><@showClass classInfoById.CONTRA_ASSET 1/></#if>
        <#if classInfoById.CURRENT_ASSET??><@showClass classInfoById.CURRENT_ASSET 1/></#if>
        <#if classInfoById.OTHER_ASSET??><@showClass classInfoById.OTHER_ASSET 1/></#if>
        <#if classInfoById.CURRENT_LIABILITY??><@showClass classInfoById.CURRENT_LIABILITY 1/></#if>

        <tr style="border-top: solid black;">
            <td><strong>${ec.l10n.localize("Investing Activities")}</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"> </td><td class="text-right"> </td><td class="text-right"> </td></#list>
        </tr>
        <#if classInfoById.LONGTERM_ASSET??><@showClass classInfoById.LONGTERM_ASSET 1/></#if>

        <tr style="border-top: solid black;">
            <td><strong>${ec.l10n.localize("Financing Activities")}</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"> </td><td class="text-right"> </td><td class="text-right"> </td></#list>
        </tr>
        <#if classInfoById.DISTRIBUTION??><@showClass classInfoById.DISTRIBUTION 1/></#if>
        <#if classInfoById.EQUITY??><@showClass classInfoById.EQUITY 1/></#if>
        <#if classInfoById.LONG_TERM_LIABILITY??><@showClass classInfoById.LONG_TERM_LIABILITY 1/></#if>
    </tbody>
</table>
