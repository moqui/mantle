<!--
This Work is in the public domain and is provided on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
including, without limitation, any warranties or conditions of TITLE,
NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.
You are solely responsible for determining the appropriateness of using
this Work and assume any risks associated with your use of this Work.

This Work includes contributions authored by David E. Jones, not as a
"work for hire", who hereby disclaims any copyright to the same.
-->

<!-- See the mantle.ledger.LedgerReportServices.run#BalanceSheet service for data preparation -->

<#macro showChildClassList childClassInfoList depth>
    <#list childClassInfoList as childClassInfo>
        <tr>
            <td><#list 1..depth as i>&nbsp;&nbsp;&nbsp;</#list>${childClassInfo.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(childClassInfo.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <#list childClassInfo.glAccountDetailList! as glAccountDetail>
            <!-- ${glAccountDetail.accountName} : ${glAccountDetail.timePeriodId} : ${glAccountDetail.endingBalance!} -->
            <#-- TODO: add detail mode that shows GL Account endingBalances for each time period (tricky because we just have a flat list, not by period... best to change prep service for this -->
        </#list>
        <#assign curDepth = depth + 1>
        <@showChildClassList childClassInfo.childClassInfoList curDepth/>
    </#list>
</#macro>

<table class="table table-striped table-hover table-condensed">
    <thead>
        <tr>
            <th>Income and Expense</th>
            <#list timePeriodIdList as timePeriodId><th class="text-right">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed})</th></#list>
        </tr>
    </thead>
    <tbody>

        <tr>
            <td>${revenueInfoMap.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(revenueInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <@showChildClassList revenueInfoMap.childClassInfoList 1/>
        <tr>
            <td>${contraRevenueInfoMap.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(contraRevenueInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <@showChildClassList contraRevenueInfoMap.childClassInfoList 1/>
        <tr>
            <td><strong>Net Sales</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"><strong>${ec.l10n.formatCurrency(revenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 - contraRevenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td></#list>
        </tr>

        <tr>
            <td>${costOfSalesInfoMap.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(costOfSalesInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <@showChildClassList costOfSalesInfoMap.childClassInfoList 1/>
        <tr>
            <td><strong>Cost of Sales Total</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"><strong>${ec.l10n.formatCurrency(costOfSalesInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td></#list>
        </tr>

        <tr>
            <td><strong>Gross Profit On Sales</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"><strong>${ec.l10n.formatCurrency((revenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 - contraRevenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0) - costOfSalesInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td></#list>
        </tr>



        <tr>
            <td>${incomeInfoMap.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(incomeInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <@showChildClassList incomeInfoMap.childClassInfoList 1/>
        <tr>
            <td>${expenseInfoMap.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(expenseInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <@showChildClassList expenseInfoMap.childClassInfoList 1/>
        <tr>
            <td><strong>Net Operating Income</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"><strong>${ec.l10n.formatCurrency(incomeInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 - expenseInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td></#list>
        </tr>
    </tbody>
    <tbody>
        <tr>
            <td><strong>Net Income</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"><strong>${ec.l10n.formatCurrency((incomeInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 + revenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0) - (contraRevenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 + costOfSalesInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 + expenseInfoMap.totalBalanceByTimePeriod[timePeriodId]!0), currencyUomId, 2)}</strong></td></#list>
        </tr>
    </tbody>
</table>
