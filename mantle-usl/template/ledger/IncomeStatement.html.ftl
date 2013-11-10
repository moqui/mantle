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
        <div class="form-row">
            <div class="form-cell"><#list 1..depth as i>&nbsp;&nbsp;&nbsp;</#list>${childClassInfo.className}</div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency">${ec.l10n.formatCurrency(childClassInfo.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
        <#list childClassInfo.glAccountDetailList! as glAccountDetail>
            <!-- ${glAccountDetail.accountName} : ${glAccountDetail.timePeriodId} : ${glAccountDetail.endingBalance!} -->
            <#-- TODO: add detail mode that shows GL Account endingBalances for each time period (tricky because we just have a flat list, not by period... best to change prep service for this -->
        </#list>
        <#assign curDepth = depth + 1>
        <@showChildClassList childClassInfo.childClassInfoList curDepth/>
    </#list>
</#macro>

<div class="form-list-outer">
    <div class="form-header-group">
        <div class="form-header-row">
            <div class="form-header-cell"><span class="form-title">Income and Expense</span></div>
            <#list timePeriodIdList as timePeriodId><div class="form-header-cell"><span class="form-title">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed})</span></div></#list>
        </div>
    </div>
    <div class="form-body">
        <div class="form-row">
            <div class="form-cell">${incomeInfoMap.className}</div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency">${ec.l10n.formatCurrency(incomeInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
        <@showChildClassList incomeInfoMap.childClassInfoList 1/>

        <div class="form-row">
            <div class="form-cell">${revenueInfoMap.className}</div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency">${ec.l10n.formatCurrency(revenueInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
        <@showChildClassList revenueInfoMap.childClassInfoList 1/>

        <div class="form-row">
            <div class="form-cell"><span class="form-title">Income Total</span></div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency form-title">${ec.l10n.formatCurrency(incomeInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 + revenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>



        <div class="form-row">
            <div class="form-cell">${expenseInfoMap.className}</div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency">${ec.l10n.formatCurrency(expenseInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
        <@showChildClassList expenseInfoMap.childClassInfoList 1/>


        <div class="form-row">
            <div class="form-cell">${contraRevenueInfoMap.className}</div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency">${ec.l10n.formatCurrency(contraRevenueInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
        <@showChildClassList contraRevenueInfoMap.childClassInfoList 1/>

        <div class="form-row">
            <div class="form-cell"><span class="form-title">Expense Total</span></div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency form-title">${ec.l10n.formatCurrency(expenseInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 + contraRevenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
    </div>
    <div class="form-body">
        <div class="form-row">
            <div class="form-cell"><span class="form-title">Net Income</span></div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency form-title">${ec.l10n.formatCurrency((incomeInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 + revenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0) - (expenseInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 + contraRevenueInfoMap.totalBalanceByTimePeriod[timePeriodId]!0), currencyUomId, 2)}</span></div></#list>
        </div>
    </div>
</div>
