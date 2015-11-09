<!--
This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->

<!-- See the mantle.ledger.LedgerReportServices.run#BalanceSheet service for data preparation -->

<#assign numFmt = "0.0000">

<#macro showRatio name ratioMap>
    <tr>
        <td>${ec.l10n.localize(name)}</td><td><i><#nested></i></td>
        <#if (timePeriodIdList?size > 1)><td class="text-right">${ec.l10n.format(ratioMap['ALL']!0, numFmt)}</td></#if>
        <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.format(ratioMap[timePeriodId]!0, numFmt)}</td></#list>
    </tr>
</#macro>
<#macro showOther name valueMap>
    <tr>
        <td>${ec.l10n.localize(name)}</td><td> </td>
        <#if (timePeriodIdList?size > 1)><td class="text-right">${ec.l10n.formatCurrency(valueMap['ALL']!0, currencyUomId, 2)}</td></#if>
        <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(valueMap[timePeriodId]!0, currencyUomId, 2)}</td></#list>
    </tr>
</#macro>

<table class="table table-striped table-hover table-condensed">
    <thead>
        <tr>
            <th>${ec.l10n.localize("Financial Ratios")}</th>
            <th>${ec.l10n.localize("Formula")}</th>
            <#if (timePeriodIdList?size > 1)><th class="text-right">All Periods</th></#if>
            <#list timePeriodIdList as timePeriodId>
                <th class="text-right">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed})</th>
            </#list>
        </tr>
    </thead>
    <tbody>
        <tr><td><strong>${ec.l10n.localize("Liquidity")}</strong></td><td> </td><#if (timePeriodIdList?size > 1)><td> </td></#if><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <@showRatio "Current Liquidity" currentLiquidityMap>${ec.l10n.localize("Current Assets")} / ${ec.l10n.localize("Current Liabilities")}</@showRatio>
        <@showRatio "Quick Liquidity" quickLiquidityMap>(${ec.l10n.localize("Current Assets")} - ${ec.l10n.localize("Inventory")}) / ${ec.l10n.localize("Current Liabilities")}</@showRatio>
        <@showRatio "Net Working Capital to Total Assets" netCapitalToAssetsMap>(${ec.l10n.localize("Current Assets")} - ${ec.l10n.localize("Inventory")}) / ${ec.l10n.localize("Total Assets")}</@showRatio>

        <tr><td><strong>${ec.l10n.localize("Activity")}</strong></td><td> </td><#if (timePeriodIdList?size > 1)><td> </td></#if><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <@showRatio "Inventory Turnover" inventoryTurnoverMap>${ec.l10n.localize("Cost of Goods Sold")} / ${ec.l10n.localize("Inventory")}</@showRatio>
        <@showRatio "Fixed Asset Turnover" fixedAssetTurnoverMap>${ec.l10n.localize("Sales")} / ${ec.l10n.localize("Net Fixed Assets")}</@showRatio>
        <@showRatio "Total Assets Turnover" totalAssetsTurnoverMap>${ec.l10n.localize("Sales")} / ${ec.l10n.localize("Total Assets")}</@showRatio>

        <tr><td><strong>${ec.l10n.localize("Leverage")}</strong></td><td> </td><#if (timePeriodIdList?size > 1)><td> </td></#if><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <@showRatio "Debt Ratio" debtRatioMap>${ec.l10n.localize("Total Liabilities")} / ${ec.l10n.localize("Total Assets")}</@showRatio>
        <@showRatio "Debt to Equity" debtToEquityMap>${ec.l10n.localize("Long Term Debt")} / ${ec.l10n.localize("Equity")}</@showRatio>
        <@showRatio "Times Interest Earned" timesInterestEarnedMap>${ec.l10n.localize("EBIT")} / ${ec.l10n.localize("Interest Expense")}</@showRatio>
        <@showRatio "Cash Coverage" cashCoverageMap>(${ec.l10n.localize("EBIT")} + ${ec.l10n.localize("Depreciation")} + ${ec.l10n.localize("Amortization")}) / ${ec.l10n.localize("Interest Expense")}</@showRatio>
        <@showRatio "Equity Multiplier" equityMultiplierMap>${ec.l10n.localize("Total Assets")} / ${ec.l10n.localize("Equity")}</@showRatio>

        <tr><td><strong>${ec.l10n.localize("Profitability")}</strong></td><td> </td><#if (timePeriodIdList?size > 1)><td> </td></#if><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <@showRatio "Gross Profit Margin" grossProfitMarginMap>${ec.l10n.localize("Gross Profit")} / ${ec.l10n.localize("Sales")}</@showRatio>
        <@showRatio "Net Profit Margin" netProfitMarginMap>${ec.l10n.localize("Net Income")} / ${ec.l10n.localize("Sales")}</@showRatio>
        <@showRatio "Return on Assets" returnOnAssetsMap>${ec.l10n.localize("Net Income")} / ${ec.l10n.localize("Total Assets")}</@showRatio>
        <@showRatio "Return on Equity" returnOnEquityMap>${ec.l10n.localize("Net Income")} / ${ec.l10n.localize("Equity")}</@showRatio>

        <tr><td><strong>${ec.l10n.localize("Metrics")}</strong></td><td> </td><#if (timePeriodIdList?size > 1)><td> </td></#if><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <@showOther "Net Income" netIncomeMap/>
        <@showOther "Sales" salesMap/>
        <@showOther "Gross Profit" grossProfitMap/>
        <@showOther "EBT (Earnings before Income Taxes)" ebtMap/>
        <@showOther "IBIE (Income before Interest Expense)" ibieMap/>
        <@showOther "EBIT (Earnings before Interest and Taxes)" ebitMap/>

        <tr><td><strong>${ec.l10n.localize("GL Class Totals")}</strong></td><td> </td><#if (timePeriodIdList?size > 1)><td> </td></#if><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <@showOther "Cost of Sales" costOfSalesMap/>
        <@showOther "Cost of Goods Sold" cogsMap/>
        <@showOther "Total Assets" totalAssetsMap/>
        <@showOther "Net Fixed Assets" netFixedAssetsMap/>
        <@showOther "Inventory" inventoryMap/>
        <@showOther "Current Assets" currentAssetsMap/>
        <@showOther "Current Liabilities" currentLiabilitiesMap/>
        <@showOther "Total Liabilities" totalLiabilitiesMap/>
        <@showOther "Long Term Debt" longTermDebtMap/>
        <@showOther "Equity" equityMap/>
        <@showOther "Accounts Receivable" accountsReceivableMap/>
        <@showOther "Depreciation" depreciationMap/>
        <@showOther "Amortization" amortizationMap/>
        <@showOther "Interest Expense" interestExpenseMap/>
    </tbody>
</table>
