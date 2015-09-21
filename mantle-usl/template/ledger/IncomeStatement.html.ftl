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

<!-- See the mantle.ledger.LedgerReportServices.run#BalanceSheet service for data preparation -->

<#assign showDetail = (detail! == "true")>

<#macro showClass classInfo depth>
    <tr>
        <td style="padding-left: ${(depth-1) * 2}.3em;">${ec.l10n.localize(classInfo.className)}</td>
        <#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(classInfo.postedByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td>
        </#list>
    </tr>
    <#list classInfo.glAccountInfoList! as glAccountInfo>
        <#if showDetail>
            <tr>
                <td style="padding-left: ${(depth-1) * 2 + 3}.3em;">${glAccountInfo.accountCode}: ${glAccountInfo.accountName}</td>
                <#list timePeriodIdList as timePeriodId>
                    <td class="text-right">${ec.l10n.formatCurrency(glAccountInfo.postedByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td>
                </#list>
            </tr>
        <#else>
            <!-- ${glAccountInfo.accountCode}: ${glAccountInfo.accountName} ${glAccountInfo.postedByTimePeriod} -->
        </#if>
    </#list>
    <#list classInfo.childClassInfoList as childClassInfo>
        <@showClass childClassInfo depth + 1/>
    </#list>
</#macro>

<table class="table table-striped table-hover table-condensed">
    <thead>
        <tr>
            <th>${ec.l10n.localize("Income Statement")}</th>
            <#list timePeriodIdList as timePeriodId>
                <th class="text-right">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed})</th>
            </#list>
        </tr>
    </thead>
    <tbody>

        <@showClass classInfoById.REVENUE 1/>
        <@showClass classInfoById.CONTRA_REVENUE 1/>
        <tr>
            <td><strong>${ec.l10n.localize("Net Sales")}</strong></td>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(classInfoById.REVENUE.totalPostedByTimePeriod[timePeriodId]!0 + classInfoById.CONTRA_REVENUE.totalPostedByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
            </#list>
        </tr>

        <@showClass classInfoById.COST_OF_SALES 1/>
        <tr>
            <td><strong>${ec.l10n.localize("Cost of Sales Total")}</strong></td>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(classInfoById.COST_OF_SALES.totalPostedByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
            </#list>
        </tr>
        <tr class="text-info" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Gross Profit On Sales")}</strong></td>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(grossProfitOnSalesMap[timePeriodId]!0, currencyUomId, 2)}</strong></td>
            </#list>
        </tr>

        <@showClass classInfoById.INCOME 1/>
        <tr>
            <td><strong>${ec.l10n.localize("Income Total")}</strong></td>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(classInfoById.INCOME.totalPostedByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
            </#list>
        </tr>
        <@showClass classInfoById.EXPENSE 1/>
        <tr>
            <td><strong>${ec.l10n.localize("Expense Total")}</strong></td>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(classInfoById.EXPENSE.totalPostedByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
            </#list>
        </tr>
        <tr class="text-info" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Net Operating Income")}</strong></td>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(netOperatingIncomeMap[timePeriodId]!0, currencyUomId, 2)}</strong></td>
            </#list>
        </tr>

        <tr class="text-success" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Net Income")}</strong></td>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(netIncomeMap[timePeriodId]!0, currencyUomId, 2)}</strong></td>
            </#list>
        </tr>
    </tbody>
</table>
