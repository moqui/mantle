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

<#-- See the mantle.work.ManufacturingServices.get#ProductionRunPickInfo service for data preparation -->

<#assign cellPadding = "1pt">
<#assign dateFormat = dateFormat!"dd MMM yyyy">
<#assign dateTimeFormat = dateTimeFormat!"yyyy-MM-dd HH:mm">

<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Helvetica, sans-serif" font-size="10pt">
    <fo:layout-master-set>
        <fo:simple-page-master master-name="letter-portrait" page-width="8.5in" page-height="11in"
                               margin-top="0.5in" margin-bottom="0.5in" margin-left="0.5in" margin-right="0.5in">
            <fo:region-body margin-top="0.5in" margin-bottom="0.6in"/>
            <fo:region-before extent="0.5in"/>
            <fo:region-after extent="0.5in"/>
        </fo:simple-page-master>
    </fo:layout-master-set>

    <fo:page-sequence master-reference="letter-portrait" initial-page-number="1" force-page-count="no-force">
        <fo:static-content flow-name="xsl-region-before">
            <fo:block font-size="12pt" text-align="center" margin-bottom="0.1in">Production Run Picklist</fo:block>
            <fo:block-container absolute-position="absolute" top="0in" right="0.5in" width="3in">
                <fo:block text-align="right">
                    <fo:instream-foreign-object>
                        <barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns" message="${workEffortId}">
                            <barcode:code128>
                                <barcode:height>0.4in</barcode:height>
                                <barcode:module-width>0.3mm</barcode:module-width>
                            </barcode:code128>
                            <barcode:human-readable>
                                <barcode:placement>bottom</barcode:placement>
                                <barcode:font-name>Helvetica</barcode:font-name>
                                <barcode:font-size>12pt</barcode:font-size>
                                <barcode:display-start-stop>false</barcode:display-start-stop>
                                <barcode:display-checksum>false</barcode:display-checksum>
                            </barcode:human-readable>
                        </barcode:barcode>
                    </fo:instream-foreign-object>
                </fo:block>
            </fo:block-container>
        </fo:static-content>
        <fo:static-content flow-name="xsl-region-after" font-size="8pt">
            <fo:block border-top="thin solid black">
                <fo:block text-align="center">Picklist for Run #${workEffortId} -- <#if workEffort.estimatedStartDate??>${ec.l10n.format(workEffort.estimatedStartDate, dateTimeFormat)} -- </#if>Printed ${ec.l10n.format(ec.user.nowTimestamp, dateTimeFormat)} -- Page <fo:page-number/></fo:block>
            </fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">
            <fo:table table-layout="fixed" margin-bottom="0.1in" width="7.5in">
                <fo:table-body><fo:table-row>
                    <fo:table-cell padding="3pt" width="3in">
                        <fo:block font-weight="bold">Run #</fo:block>
                        <fo:block>${workEffortId}</fo:block>
                        <#if warehouseFacility?has_content>
                            <fo:block font-weight="bold">Warehouse</fo:block>
                            <fo:block>${ec.resource.expand("FacilityNameTemplate", "", warehouseFacility)}</fo:block>
                        </#if>
                        <#if lineFacility?has_content>
                            <fo:block font-weight="bold">Line</fo:block>
                            <fo:block>${ec.resource.expand("FacilityNameTemplate", "", lineFacility)}</fo:block>
                        </#if>
                    </fo:table-cell>
                    <fo:table-cell padding="3pt" width="1.5in">
                        <#if workEffort.estimatedStartDate?exists>
                            <fo:block font-weight="bold">Est. Start</fo:block>
                            <fo:block>${ec.l10n.format(workEffort.estimatedStartDate, dateTimeFormat)}</fo:block>
                        </#if>
                        <#if workEffort.estimatedWorkDuration?exists>
                            <fo:block font-weight="bold">Est. Hours</fo:block>
                            <fo:block>${workEffort.estimatedWorkDuration}</fo:block>
                        </#if>
                    </fo:table-cell>
                    <fo:table-cell padding="3pt" width="3in">
                        <fo:block font-weight="bold">Equipment</fo:block>
                        <#if equipmentList?has_content>
                            <#list equipmentList as equipment>
                                <fo:block>${ec.resource.expand("AssetNameTemplate", "", equipment)}</fo:block>
                            </#list>
                        </#if>
                    </fo:table-cell>
                </fo:table-row></fo:table-body>
            </fo:table>

            <#if locationInfoList?has_content>
                <fo:table table-layout="fixed" width="7.5in" border-bottom="solid black">
                    <fo:table-header font-size="9pt" font-weight="bold" border-bottom="solid black">
                        <fo:table-cell width="2in" padding="${cellPadding}"><fo:block text-align="left">By Location</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Area</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Aisle</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Sec</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Level</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Pos</fo:block></fo:table-cell>

                        <fo:table-cell width="2in" padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                        <fo:table-cell width="1in" padding="${cellPadding}"><fo:block text-align="right">Quantity</fo:block></fo:table-cell>
                    </fo:table-header>
                    <fo:table-body>
                    <#list locationInfoList as locationInfo>
                        <fo:table-row font-size="9pt" border-top="solid black">
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${locationInfo.description!"No Location"}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.areaId!" "}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.aisleId!" "}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.sectionId!" "}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.levelId!" "}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.positionId!" "}</fo:block></fo:table-cell>

                            <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                        </fo:table-row>
                        <#list locationInfo.productInfoList as productInfo>
                            <fo:table-row font-size="9pt">
                                <fo:table-cell padding="${cellPadding}" number-columns-spanned="4"><fo:block text-align="center">
                                    <fo:instream-foreign-object>
                                        <barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns" message="${productInfo.productId}">
                                            <barcode:code128>
                                                <barcode:height>0.4in</barcode:height>
                                                <barcode:module-width>0.25mm</barcode:module-width>
                                            </barcode:code128>
                                            <barcode:human-readable>
                                                <barcode:placement>bottom</barcode:placement>
                                                <barcode:font-name>Helvetica</barcode:font-name>
                                                <barcode:font-size>7pt</barcode:font-size>
                                                <barcode:display-start-stop>false</barcode:display-start-stop>
                                                <barcode:display-checksum>false</barcode:display-checksum>
                                            </barcode:human-readable>
                                        </barcode:barcode>
                                    </fo:instream-foreign-object>
                                </fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}" number-columns-spanned="3"><fo:block text-align="left">${ec.resource.expand("ProductNameTemplate", "", productInfo)}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${productInfo.quantity}</fo:block></fo:table-cell>
                            </fo:table-row>
                        </#list>
                    </#list>
                    </fo:table-body>
                </fo:table>
            </#if>
            <#if productInfoList?has_content>
                <fo:table table-layout="fixed" width="7.5in" border-bottom="solid black" margin-top="10pt">
                    <fo:table-header font-size="9pt" font-weight="bold" border-bottom="solid black">
                        <fo:table-cell width="2in" padding="${cellPadding}"><fo:block text-align="left">By Product</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Area</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Aisle</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Sec</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Level</fo:block></fo:table-cell>
                        <fo:table-cell width="0.5in" padding="${cellPadding}"><fo:block text-align="center">Pos</fo:block></fo:table-cell>

                        <fo:table-cell width="2in" padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                        <fo:table-cell width="1in" padding="${cellPadding}"><fo:block text-align="right">Quantity</fo:block></fo:table-cell>
                    </fo:table-header>
                    <fo:table-body>
                    <#list productInfoList as productInfo>
                        <fo:table-row font-size="9pt" border-top="solid black">
                            <fo:table-cell padding="${cellPadding}" number-columns-spanned="4"><fo:block text-align="center">
                                <fo:instream-foreign-object>
                                    <barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns" message="${productInfo.productId}">
                                        <barcode:code128>
                                            <barcode:height>0.4in</barcode:height>
                                            <barcode:module-width>0.25mm</barcode:module-width>
                                        </barcode:code128>
                                        <barcode:human-readable>
                                            <barcode:placement>bottom</barcode:placement>
                                            <barcode:font-name>Helvetica</barcode:font-name>
                                            <barcode:font-size>7pt</barcode:font-size>
                                            <barcode:display-start-stop>false</barcode:display-start-stop>
                                            <barcode:display-checksum>false</barcode:display-checksum>
                                        </barcode:human-readable>
                                    </barcode:barcode>
                                </fo:instream-foreign-object>
                            </fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}" number-columns-spanned="3"><fo:block text-align="left">${ec.resource.expand("ProductNameTemplate", "", productInfo)}</fo:block></fo:table-cell>
                            <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${productInfo.quantity}</fo:block></fo:table-cell>
                        </fo:table-row>
                        <#if productInfo.locationInfoList?has_content><#list productInfo.locationInfoList as locationInfo>
                            <fo:table-row font-size="9pt">
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="left">${locationInfo.description!"No Location"}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.areaId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.aisleId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.sectionId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.levelId!" "}</fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="center">${locationInfo.positionId!" "}</fo:block></fo:table-cell>

                                <fo:table-cell padding="${cellPadding}"><fo:block> </fo:block></fo:table-cell>
                                <fo:table-cell padding="${cellPadding}"><fo:block text-align="right">${locationInfo.quantity}</fo:block></fo:table-cell>
                            </fo:table-row>
                        </#list></#if>
                    </#list>
                    </fo:table-body>
                </fo:table>
            </#if>
        </fo:flow>
    </fo:page-sequence>
</fo:root>
