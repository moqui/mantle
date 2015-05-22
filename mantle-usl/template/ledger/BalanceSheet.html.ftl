<!--
This is free and unencumbered software released into the public domain.
For specific language governing permissions and limitations refer to
the LICENSE.md file or http://unlicense.org
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
            <th>Balance Sheet</th>
            <#list timePeriodIdList as timePeriodId><th class="text-right">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed})</th></#list>
        </tr>
    </thead>
    <tbody>
        <#if assetInfoMap??>
        <tr>
            <td>${assetInfoMap.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(assetInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <@showChildClassList assetInfoMap.childClassInfoList 1/>
        </#if>

        <#if contraAssetInfoMap??>
        <tr>
            <td>${contraAssetInfoMap.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(contraAssetInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <@showChildClassList contraAssetInfoMap.childClassInfoList 1/>
        </#if>

        <#if assetInfoMap?? && contraAssetInfoMap??>
        <tr>
            <td><strong>Asset - Contra Asset Total</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"><strong>${ec.l10n.formatCurrency(assetInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 - contraAssetInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td></#list>
        </tr>
        </#if>
    </tbody>



    <tbody>
        <#if liabilityInfoMap??>
        <tr>
            <td>${liabilityInfoMap.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(liabilityInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <@showChildClassList liabilityInfoMap.childClassInfoList 1/>
        </#if>


        <#if equityInfoMap??>
        <tr>
            <td>${equityInfoMap.className}</td>
            <#list timePeriodIdList as timePeriodId><td class="text-right">${ec.l10n.formatCurrency(equityInfoMap.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td></#list>
        </tr>
        <@showChildClassList equityInfoMap.childClassInfoList 1/>
        </#if>

        <#if liabilityInfoMap?? && equityInfoMap??>
        <tr>
            <td><strong>Liability + Equity Total</strong></td>
            <#list timePeriodIdList as timePeriodId><td class="text-right"><strong>${ec.l10n.formatCurrency(liabilityInfoMap.totalBalanceByTimePeriod[timePeriodId]!0 + equityInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td></#list>
        </tr>
        </#if>
    </tbody>
</table>
