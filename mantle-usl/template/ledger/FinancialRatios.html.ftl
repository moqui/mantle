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

<table class="table table-striped table-hover table-condensed">
    <thead>
        <tr>
            <th>${ec.l10n.localize("Financial Ratios")}</th>
            <th>${ec.l10n.localize("Formula")}</th>
            <#list timePeriodIdList as timePeriodId>
                <th class="text-right">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed})</th>
            </#list>
        </tr>
    </thead>
    <tbody>
        <tr><td><strong>${ec.l10n.localize("Liquidity")}</strong></td><td> </td><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <tr><td>${ec.l10n.localize("Current Liquidity")}</td><td><i>${ec.l10n.localize("Current Assets")} / ${ec.l10n.localize("Current Liabilities")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(currentLiquidityMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Quick Liquidity")}</td><td><i>(${ec.l10n.localize("Current Assets")} - ${ec.l10n.localize("Inventory")}) / ${ec.l10n.localize("Current Liabilities")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(quickLiquidityMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Net Working Capital to Total Assets")}</td><td><i>(${ec.l10n.localize("Current Assets")} - ${ec.l10n.localize("Inventory")}) / ${ec.l10n.localize("Total Assets")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(netCapitalToAssetsMap[timePeriodId]!0, "0.0000")}</td></#list></tr>

        <tr><td><strong>${ec.l10n.localize("Activity")}</strong></td><td> </td><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <tr><td>${ec.l10n.localize("Inventory Turnover")}</td><td><i>${ec.l10n.localize("Cost of Goods Sold")} / ${ec.l10n.localize("Inventory")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(inventoryTurnoverMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Fixed Asset Turnover")}</td><td><i>${ec.l10n.localize("Sales")} / ${ec.l10n.localize("Net Fixed Assets")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(fixedAssetTurnoverMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Total Assets Turnover")}</td><td><i>${ec.l10n.localize("Sales")} / ${ec.l10n.localize("Total Assets")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(totalAssetsTurnoverMap[timePeriodId]!0, "0.0000")}</td></#list></tr>

        <tr><td><strong>${ec.l10n.localize("Leverage")}</strong></td><td> </td><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <tr><td>${ec.l10n.localize("Debt Ratio")}</td><td><i>${ec.l10n.localize("Total Liabilities")} / ${ec.l10n.localize("Total Assets")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(debtRatioMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Debt to Equity")}</td><td><i>${ec.l10n.localize("Long Term Debt")} / ${ec.l10n.localize("Equity")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(debtToEquityMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Times Interest Earned")}</td><td><i>${ec.l10n.localize("EBIT")} / ${ec.l10n.localize("Interest Expense")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(timesInterestEarnedMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Cash Coverage")}</td><td><i>(${ec.l10n.localize("EBIT")} + ${ec.l10n.localize("Depreciation")} + ${ec.l10n.localize("Amortization")}) / ${ec.l10n.localize("Interest Expense")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(cashCoverageMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Equity Multiplier")}</td><td><i>${ec.l10n.localize("Total Assets")} / ${ec.l10n.localize("Equity")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(equityMultiplierMap[timePeriodId]!0, "0.0000")}</td></#list></tr>

        <tr><td><strong>${ec.l10n.localize("Profitability")}</strong></td><td> </td><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <tr><td>${ec.l10n.localize("Gross Profit Margin")}</td><td><i>${ec.l10n.localize("Gross Profit")} / ${ec.l10n.localize("Sales")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(grossProfitMarginMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Net Profit Margin")}</td><td><i>${ec.l10n.localize("Net Income")} / ${ec.l10n.localize("Sales")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(netProfitMarginMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Return on Assets")}</td><td><i>${ec.l10n.localize("Net Income")} / ${ec.l10n.localize("Total Assets")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(returnOnAssetsMap[timePeriodId]!0, "0.0000")}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Return on Equity")}</td><td><i>${ec.l10n.localize("Net Income")} / ${ec.l10n.localize("Equity")}</i></td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.format(returnOnEquityMap[timePeriodId]!0, "0.0000")}</td></#list></tr>

        <tr><td><strong>${ec.l10n.localize("Metrics")}</strong></td><td> </td><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <tr><td>${ec.l10n.localize("Net Income")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(netIncomeMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Sales")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(salesMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Gross Profit")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(grossProfitMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("EBT (Earnings before Income Taxes)")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(ebtMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("IBIE (Income before Interest Expense)")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(ibieMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("EBIT (Earnings before Interest and Taxes)")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(ebitMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>

        <tr><td><strong>${ec.l10n.localize("GL Class Totals")}</strong></td><td> </td><#list timePeriodIdList as timePeriodId><td> </td></#list></tr>
        <tr><td>${ec.l10n.localize("Cost of Sales")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(costOfSalesMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Cost of Goods Sold")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(cogsMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Total Assets")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(totalAssetsMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Net Fixed Assets")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(netFixedAssetsMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Inventory")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(inventoryMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Current Assets")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(currentAssetsMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Current Liabilities")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(currentLiabilitiesMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Total Liabilities")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(totalLiabilitiesMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Long Term Debt")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(longTermDebtMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Equity")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(equityMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Accounts Receivable")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(accountsReceivableMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Depreciation")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(depreciationMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Amortization")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(amortizationMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
        <tr><td>${ec.l10n.localize("Interest Expense")}</td><td> </td><#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(interestExpenseMap[timePeriodId]!0, currencyUomId, 2)}</td></#list></tr>
    </tbody>
</table>
