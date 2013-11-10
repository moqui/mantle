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
            <div class="form-header-cell"><span class="form-title">Balance Sheet</span></div>
            <#list timePeriodIdList as timePeriodId><div class="form-header-cell"><span class="form-title">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed})</span></div></#list>
        </div>
    </div>
    <div class="form-body">
        <div class="form-row">
            <div class="form-cell">${assetInfoMap.className}</div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency">${ec.l10n.formatCurrency(assetInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
        <@showChildClassList assetInfoMap.childClassInfoList 1/>

        <div class="form-row">
            <div class="form-cell">${contraAssetInfoMap.className}</div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency">${ec.l10n.formatCurrency(contraAssetInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
        <@showChildClassList contraAssetInfoMap.childClassInfoList 1/>

        <div class="form-row">
            <div class="form-cell"><span class="form-title">Asset - Contra Asset Total</span></div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency form-title">${ec.l10n.formatCurrency(assetInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 - contraAssetInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
    </div>



    <div class="form-body">
        <div class="form-row">
            <div class="form-cell">${liabilityInfoMap.className}</div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency">${ec.l10n.formatCurrency(liabilityInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
        <@showChildClassList liabilityInfoMap.childClassInfoList 1/>


        <div class="form-row">
            <div class="form-cell">${equityInfoMap.className}</div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency">${ec.l10n.formatCurrency(equityInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
        <@showChildClassList equityInfoMap.childClassInfoList 1/>

        <div class="form-row">
            <div class="form-cell"><span class="form-title">Liability + Equity Total</span></div>
            <#list timePeriodIdList as timePeriodId><div class="form-cell"><span class="currency form-title">${ec.l10n.formatCurrency(liabilityInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 + equityInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</span></div></#list>
        </div>
    </div>
</div>
