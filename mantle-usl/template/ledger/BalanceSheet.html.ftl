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
            <td class="text-right">${ec.l10n.formatCurrency(classInfo.balanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</td>
        </#list>
    </tr>
    <#list classInfo.glAccountInfoList! as glAccountInfo>
        <#if showDetail>
            <tr>
                <td style="padding-left: ${(depth-1) * 2 + 3}.3em;">${glAccountInfo.accountCode}: ${glAccountInfo.accountName}</td>
                <#list timePeriodIdList as timePeriodId>
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
</#macro>

<table class="table table-striped table-hover table-condensed">
    <thead>
        <tr>
            <th>${ec.l10n.localize("Balance Sheet")}</th>
            <#list timePeriodIdList as timePeriodId>
                <th class="text-right">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed})</th>
            </#list>
        </tr>
    </thead>
    <tbody>
        <#if assetInfoMap??>
            <@showClass assetInfoMap 1/>
            <tr>
                <td><strong>${ec.l10n.localize("Asset Total")}</strong></td>
                <#list timePeriodIdList as timePeriodId>
                    <td class="text-right"><strong>${ec.l10n.formatCurrency(assetInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
                </#list>
            </tr>
        </#if>

        <#if contraAssetInfoMap??>
            <@showClass contraAssetInfoMap 1/>
            <tr>
                <td><strong>${ec.l10n.localize("Contra Asset Total")}</strong></td>
                <#list timePeriodIdList as timePeriodId>
                    <td class="text-right"><strong>${ec.l10n.formatCurrency(contraAssetInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
                </#list>
            </tr>
        </#if>

        <#if assetInfoMap?? && contraAssetInfoMap??>
            <tr class="text-info" style="border-bottom: solid black;">
                <td><strong>${ec.l10n.localize("Net Asset Total")}</strong></td>
                <#list timePeriodIdList as timePeriodId>
                    <td class="text-right"><strong>${ec.l10n.formatCurrency(netAssetTotalMap[timePeriodId]!0, currencyUomId, 2)}</strong></td>
                </#list>
            </tr>
        </#if>

        <#if liabilityInfoMap??>
            <@showClass liabilityInfoMap 1/>
            <tr>
                <td><strong>${ec.l10n.localize("Liability Total")}</strong></td>
                <#list timePeriodIdList as timePeriodId>
                    <td class="text-right"><strong>${ec.l10n.formatCurrency(liabilityInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
                </#list>
            </tr>
        </#if>


        <#if equityInfoMap??>
            <@showClass equityInfoMap 1/>
            <tr>
                <td><strong>${ec.l10n.localize("Equity Total")}</strong></td>
                <#list timePeriodIdList as timePeriodId>
                    <td class="text-right"><strong>${ec.l10n.formatCurrency(equityInfoMap.totalBalanceByTimePeriod[timePeriodId]!0, currencyUomId, 2)}</strong></td>
                </#list>
            </tr>
        </#if>

        <#if liabilityInfoMap?? && equityInfoMap??>
            <tr class="text-info" style="border-bottom: solid black;">
                <td><strong>${ec.l10n.localize("Liability + Equity Total")}</strong></td>
                <#list timePeriodIdList as timePeriodId>
                    <td class="text-right"><strong>${ec.l10n.formatCurrency(liabilityEquityTotalMap[timePeriodId]!0, currencyUomId, 2)}</strong></td>
                </#list>
            </tr>
        </#if>
    </tbody>
</table>
