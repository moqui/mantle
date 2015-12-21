/*
 * This software is in the public domain under CC0 1.0 Universal plus a 
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

import org.moqui.Moqui
import org.moqui.context.ExecutionContext
import org.moqui.entity.EntityList
import org.moqui.entity.EntityValue
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import spock.lang.Shared
import spock.lang.Specification

import java.sql.Timestamp

/* To run these make sure moqui, and mantle are in place and run:
    "gradle cleanAll load runtime/mantle/mantle-usl:test"
   Or to quick run with saved DB copy use "gradle loadSave" once then each time "gradle reloadSave runtime/mantle/mantle-usl:test"
 */

class ReturnToResponseBasicFlow extends Specification {
    @Shared
    protected final static Logger logger = LoggerFactory.getLogger(ReturnToResponseBasicFlow.class)
    @Shared
    ExecutionContext ec
    @Shared
    String returnId = null, originalOrderId = "55500", returnShipmentId
    @Shared
    Map replaceShipResult
    @Shared
    long effectiveTime = System.currentTimeMillis()

    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        // set an effective date so data check works, etc
        ec.user.setEffectiveTime(new Timestamp(effectiveTime))

        ec.entity.tempSetSequencedIdPrimary("mantle.account.invoice.Invoice", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.financial.FinancialAccount", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.financial.FinancialAccountTrans", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.method.PaymentGatewayResponse", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.payment.Payment", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.payment.PaymentApplication", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.asset.Asset", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.asset.AssetDetail", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.issuance.AssetReservation", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.issuance.AssetIssuance", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.receipt.AssetReceipt", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.order.OrderHeader", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.order.return.ReturnHeader", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.order.return.ReturnItemBilling", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.shipment.Shipment", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.shipment.ShipmentItemSource", 55700, 10)
    }

    def cleanupSpec() {
        ec.entity.tempResetSequencedIdPrimary("mantle.account.invoice.Invoice")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.financial.FinancialAccount")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.financial.FinancialAccountTrans")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.method.PaymentGatewayResponse")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.payment.Payment")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.payment.PaymentApplication")
        ec.entity.tempResetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.asset.Asset")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.asset.AssetDetail")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.issuance.AssetReservation")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.issuance.AssetIssuance")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.receipt.AssetReceipt")
        ec.entity.tempResetSequencedIdPrimary("mantle.order.OrderHeader")
        ec.entity.tempResetSequencedIdPrimary("mantle.order.return.ReturnHeader")
        ec.entity.tempResetSequencedIdPrimary("mantle.order.return.ReturnItemBilling")
        ec.entity.tempResetSequencedIdPrimary("mantle.shipment.Shipment")
        ec.entity.tempResetSequencedIdPrimary("mantle.shipment.ShipmentItemSource")
        ec.destroy()
    }

    def setup() {
        ec.artifactExecution.disableAuthz()
    }

    def cleanup() {
        ec.artifactExecution.enableAuthz()
    }

    def "create Return From Order"() {
        when:
        ec.user.loginUser("joe@public.com", "moqui", null)

        // create return
        Map createMap = ec.service.sync().name("mantle.order.ReturnServices.create#ReturnFromOrder")
                .parameters([orderId:originalOrderId, orderPartSeqId:'01']).call()
        returnId = createMap.returnId

        // add items
        ec.service.sync().name("mantle.order.ReturnServices.add#OrderItemToReturn")
                .parameters([returnId:returnId, orderId:originalOrderId, orderItemSeqId:'01', returnQuantity:1,
                             returnReasonEnumId:'RrsnMisShip', returnResponseEnumId:'RrspReplace']).call()
        ec.service.sync().name("mantle.order.ReturnServices.add#OrderItemToReturn")
                .parameters([returnId:returnId, orderId:originalOrderId, orderItemSeqId:'02', returnQuantity:2,
                             returnReasonEnumId:'RrsnDefective', returnResponseEnumId:'RrspRefund']).call()
        ec.service.sync().name("mantle.order.ReturnServices.add#OrderItemToReturn")
                .parameters([returnId:returnId, orderId:originalOrderId, orderItemSeqId:'03', returnQuantity:1,
                             returnReasonEnumId:'RrsnDidNotWant', returnResponseEnumId:'RrspCredit']).call()

        // submit return request
        ec.service.sync().name("mantle.order.ReturnServices.request#Return").parameters([returnId:returnId]).call()

        ec.user.logoutUser()

        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <returns returnId="55700" facilityId="ORG_ZIZI_RETAIL_WH" entryDate="${effectiveTime}"
                    shipmentMethodEnumId="ShMthGround" vendorPartyId="ORG_ZIZI_RETAIL" telecomContactMechId="CustJqpTeln"
                    postalContactMechId="CustJqpAddr" carrierPartyId="_NA_" currencyUomId="USD" statusId="ReturnRequested"
                    paymentMethodId="CustJqpCc" customerPartyId="CustJqp">
                <items returnItemSeqId="01" orderId="55500" orderItemSeqId="01" returnReasonEnumId="RrsnMisShip"
                    returnQuantity="1" productId="DEMO_1_1" description="Demo Product One-One" itemTypeEnumId="ItemProduct"
                    statusId="ReturnRequested" returnResponseEnumId="RrspReplace"/>
                <items returnItemSeqId="02" orderId="55500" orderItemSeqId="02" returnReasonEnumId="RrsnDefective"
                    returnQuantity="2" productId="DEMO_3_1" description="Demo Product Three-One" itemTypeEnumId="ItemProduct"
                    statusId="ReturnRequested" returnResponseEnumId="RrspRefund"/>
                <items returnItemSeqId="03" orderId="55500" orderItemSeqId="03" returnReasonEnumId="RrsnDidNotWant"
                    returnQuantity="1" productId="DEMO_2_1" description="Demo Product Two-One" itemTypeEnumId="ItemProduct"
                    statusId="ReturnRequested" returnResponseEnumId="RrspCredit"/>
            </returns>
        </entity-facade-xml>""").check()
        logger.info("create Return From Order data check results: " + dataCheckErrors)

        then:

        dataCheckErrors.size() == 0
    }

    def "approve Return"() {
        when:
        ec.user.loginUser("john.doe", "moqui", null)

        // triggers SECA rule to create an Sales Return (incoming) Shipment
        ec.service.sync().name("mantle.order.ReturnServices.approve#Return").parameters([returnId:returnId]).call()

        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <returns returnId="55700" statusId="ReturnApproved"/>
        </entity-facade-xml>""").check()
        logger.info("approve Return data check results: ")
        for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)

        then:
        dataCheckErrors.size() == 0
    }

    def "receive Return Shipment"() {
        when:

        // find Shipment created on return approve
        EntityList sisEl = ec.entity.find("mantle.shipment.ShipmentItemSource").condition("returnId", returnId).list()
        returnShipmentId = sisEl.get(0).shipmentId

        // receive Return Shipment
        // triggers SECA rules to receive ReturnItems
        ec.service.sync().name("mantle.shipment.ShipmentServices.receive#EntireShipment").parameters([shipmentId:returnShipmentId]).call()

        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <shipments shipmentId="55700" fromPartyId="CustJqp" toPartyId="ORG_ZIZI_RETAIL"
                    shipmentTypeEnumId="ShpTpSalesReturn" statusId="ShipDelivered">
                <items quantity="1" productId="DEMO_1_1">
                    <sources shipmentItemSourceId="55700" quantity="1" statusId="SisReceived" quantityNotHandled="0"
                        returnId="55700" returnItemSeqId="01"/>
                </items>
                <items quantity="1" productId="DEMO_2_1">
                    <sources shipmentItemSourceId="55702" quantity="1" statusId="SisReceived" quantityNotHandled="0"
                        returnId="55700" returnItemSeqId="03"/>
                </items>
                <items quantity="2" productId="DEMO_3_1">
                    <sources shipmentItemSourceId="55701" quantity="2" statusId="SisReceived" quantityNotHandled="0"
                        returnId="55700" returnItemSeqId="02"/>
                </items>
                <routeSegments shipmentRouteSegmentSeqId="01" shipmentMethodEnumId="ShMthGround"
                    destinationFacilityId="ORG_ZIZI_RETAIL_WH" originPostalContactMechId="CustJqpAddr"
                    carrierPartyId="_NA_" originTelecomContactMechId="CustJqpTeln"/>
            </shipments>
        </entity-facade-xml>""").check()
        logger.info("receive Return Shipment data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Return Completed"() {
        when:
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <returns returnId="55700" statusId="ReturnCompleted">
                <items returnItemSeqId="01" responseDate="${effectiveTime}" replacementOrderId="55700"
                        statusId="ReturnCompleted" receivedQuantity="1">
                    <receipts assetReceiptId="55700" productId="DEMO_1_1" quantityAccepted="1"
                        acctgTransResultEnumId="AtrNoAcquireCost" quantityRejected="0" assetId="55700" shipmentId="55700"
                        receivedByUserId="EX_JOHN_DOE" receivedDate="${effectiveTime}"/>
                    <mantle.product.asset.AssetDetail assetDetailId="55700" productId="DEMO_1_1" assetId="55700"
                        availableToPromiseDiff="1" shipmentId="55700" assetReceiptId="55700" effectiveDate="${effectiveTime}"
                        quantityOnHandDiff="1"/>
                </items>
                <items returnItemSeqId="02" orderItemSeqId="02" responseDate="${effectiveTime}" refundPaymentId="55700"
                        statusId="ReturnCompleted" responseAmount="15.54" receivedQuantity="2">
                    <receipts assetReceiptId="55702" productId="DEMO_3_1" quantityAccepted="2"
                        acctgTransResultEnumId="AtrNoAcquireCost" quantityRejected="0" assetId="55702" shipmentId="55700"
                        receivedByUserId="EX_JOHN_DOE" receivedDate="${effectiveTime}"/>
                    <mantle.product.asset.AssetDetail assetDetailId="55704" productId="DEMO_3_1" assetId="55702"
                        availableToPromiseDiff="2" shipmentId="55700" assetReceiptId="55702" effectiveDate="${effectiveTime}"
                        quantityOnHandDiff="2"/>
                </items>
                <items returnItemSeqId="03" finAccountTransId="55700" statusId="ReturnCompleted" responseAmount="12.12"
                        receivedQuantity="1">
                    <receipts assetReceiptId="55701" productId="DEMO_2_1" quantityAccepted="1"
                        acctgTransResultEnumId="AtrNoAcquireCost" quantityRejected="0" assetId="55701" shipmentId="55700"
                        receivedByUserId="EX_JOHN_DOE" receivedDate="${effectiveTime}"/>
                    <mantle.product.asset.AssetDetail assetDetailId="55703" productId="DEMO_2_1" assetId="55701"
                        availableToPromiseDiff="1" shipmentId="55700" assetReceiptId="55701" effectiveDate="${effectiveTime}"
                        quantityOnHandDiff="1"/>
                </items>
            </returns>
        </entity-facade-xml>""").check()
        logger.info("validate Refund Payment and Customer Credit TX data check results: ")
        for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Replacement Order and Asset Reservation"() {
        when:
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <orders orderId="55700" entryDate="${effectiveTime}" grandTotal="0" orderRevision="7" currencyUomId="USD"
                    statusId="OrderApproved" placedDate="${effectiveTime}">
                <parts shipmentMethodEnumId="ShMthGround" telecomContactMechId="CustJqpTeln" postalContactMechId="CustJqpAddr" partTotal="0" customerPartyId="CustJqp" lastUpdatedStamp="1450573654119" facilityId="ORG_ZIZI_RETAIL_WH" vendorPartyId="ORG_ZIZI_RETAIL" carrierPartyId="_NA_" statusId="OrderApproved" orderPartSeqId="01"/>
                <items orderItemSeqId="01" isModifiedPrice="N" itemTypeEnumId="ItemProduct" quantity="1"
                        itemDescription="Demo Product One-One" productId="DEMO_1_1" unitAmount="0" orderPartSeqId="01">
                    <reservations reservedDate="${effectiveTime}" quantity="1" productId="DEMO_1_1" sequenceNum="0"
                            quantityNotIssued="1" assetReservationId="55701" assetId="55400" quantityNotAvailable="0"
                            reservationOrderEnumId="AsResOrdFifoRec">
                        <mantle.product.asset.AssetDetail assetDetailId="55705" assetId="55400" productId="DEMO_1_1"
                            availableToPromiseDiff="-1" effectiveDate="${effectiveTime}"/>
                    </reservations>
                </items>
            </orders>
        </entity-facade-xml>""").check()
        logger.info("validate Replacement Order and Asset Reservation data check results: ")
        for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Refund Payment"() {
        when:
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <payments paymentId="55700" fromPartyId="ORG_ZIZI_RETAIL" toPartyId="CustJqp" amountUomId="USD"
                paymentTypeEnumId="PtRefund" toPaymentMethodId="CustJqpCc" amount="15.54" reconcileStatusId="PmtrNot"
                statusId="PmntPromised" paymentInstrumentEnumId="PiCompanyCheck" effectiveDate="${effectiveTime}"/>
        </entity-facade-xml>""").check()
        logger.info("validate Refund Payment data check results: ")
        for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Customer Credit Financial Account Trans"() {
        when:
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.account.financial.FinancialAccount finAccountId="55700" finAccountTypeId="CustomerCredit" isRefundable="Y"
                    availableBalance="12.12" ownerPartyId="CustJqp" currencyUomId="USD" statusId="FaActive"
                    finAccountName="Joe Public Customer Credit" actualBalance="12.12" organizationPartyId="ORG_ZIZI_RETAIL">
                <mantle.account.financial.FinancialAccountTrans finAccountTransId="55700" fromPartyId="ORG_ZIZI_RETAIL"
                        finAccountTransTypeEnumId="FattDeposit" reasonEnumId="FatrCsCredit" amount="12.12"
                        entryDate="${effectiveTime}" acctgTransResultEnumId="AtrSuccess" transactionDate="${effectiveTime}"
                        postBalance="12.12" toPartyId="CustJqp" performedByUserId="EX_JOHN_DOE"/>
            </mantle.account.financial.FinancialAccount>
            <mantle.ledger.transaction.AcctgTrans acctgTransId="55700" otherPartyId="CustJqp" postedDate="${effectiveTime}"
                    amountUomId="USD" isPosted="Y" acctgTransTypeEnumId="AttFinancialDeposit"
                    glFiscalTypeEnumId="GLFT_ACTUAL" transactionDate="${effectiveTime}" organizationPartyId="ORG_ZIZI_RETAIL">
                <mantle.ledger.transaction.AcctgTransEntry acctgTransEntrySeqId="01" amount="12.12" glAccountId="430000000"
                        reconcileStatusId="AterNot" isSummary="N" glAccountTypeEnumId="GatSales" debitCreditFlag="D"/>
                <mantle.ledger.transaction.AcctgTransEntry acctgTransEntrySeqId="02" amount="12.12" glAccountId="251100000"
                        reconcileStatusId="AterNot" isSummary="N" glAccountTypeEnumId="GatCustomerCredits" debitCreditFlag="C"/>
            </mantle.ledger.transaction.AcctgTrans>
        </entity-facade-xml>""").check()
        logger.info("validate Customer Credit Financial Account Trans data check results: ")
        for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)

        then:
        dataCheckErrors.size() == 0
    }

    def "ship Replacement Order"() {
        when:

        // the first ReturnItem is the replace item
        EntityValue returnItem = ec.entity.find("mantle.order.return.ReturnItem").condition([returnId:returnId, returnItemSeqId:'01']).one()
        replaceShipResult = ec.service.sync().name("mantle.shipment.ShipmentServices.ship#OrderPart")
                .parameters([orderId:returnItem.replacementOrderId, orderPartSeqId:'01']).call()

        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <shipments shipmentId="55701" fromPartyId="ORG_ZIZI_RETAIL" toPartyId="CustJqp"
                    shipmentTypeEnumId="ShpTpSales" statusId="ShipShipped">
                <items quantity="1" productId="DEMO_1_1">
                    <sources shipmentItemSourceId="55703" quantity="1" orderId="55700" orderItemSeqId="01"
                            statusId="SisPacked" quantityNotHandled="0"/>
                    <contents shipmentPackageSeqId="01" quantity="1"/>
                </items>
                <packages shipmentPackageSeqId="01">
                    <contents quantity="1" productId="DEMO_1_1"/>
                    <routeSegments shipmentRouteSegmentSeqId="01"/>
                </packages>
                <routeSegments shipmentRouteSegmentSeqId="01" shipmentMethodEnumId="ShMthGround"
                        actualStartDate="${effectiveTime}" destTelecomContactMechId="CustJqpTeln"
                        originFacilityId="ORG_ZIZI_RETAIL_WH" destPostalContactMechId="CustJqpAddr"/>
            </shipments>
        </entity-facade-xml>""").check()
        logger.info("ship Replacement Order data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Replacement Order Complete"() {
        when:
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- OrderHeader status to Completed -->
            <orders orderId="55700" orderRevision="8" statusId="OrderCompleted">
                <parts orderPartSeqId="01" statusId="OrderCompleted"/></orders>
        </entity-facade-xml>""").check()
        logger.info("validate Replacement Order Complete data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Asset Issuance and Accounting Transactions"() {
        when:
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.product.issuance.AssetIssuance assetIssuanceId="55700" assetId="55400" shipmentId="55701"
                    orderId="55700" orderItemSeqId="01" issuedDate="${effectiveTime}" quantity="1" productId="DEMO_1_1"
                    assetReservationId="55701" acctgTransResultEnumId="AtrSuccess">
                <mantle.ledger.transaction.AcctgTrans postedDate="${effectiveTime}" amountUomId="USD" isPosted="Y"
                        assetId="55400" acctgTransTypeEnumId="AttInventoryIssuance" glFiscalTypeEnumId="GLFT_ACTUAL"
                        transactionDate="${effectiveTime}" acctgTransId="55701" organizationPartyId="ORG_ZIZI_RETAIL">
                    <mantle.ledger.transaction.AcctgTransEntry amount="8" productId="DEMO_1_1" glAccountId="141300000"
                            reconcileStatusId="AterNot" isSummary="N" glAccountTypeEnumId="GatInventory"
                            debitCreditFlag="C" assetId="55400" acctgTransEntrySeqId="01"/>
                    <mantle.ledger.transaction.AcctgTransEntry amount="8" productId="DEMO_1_1" glAccountId="512000000"
                            reconcileStatusId="AterNot" isSummary="N" glAccountTypeEnumId="GatCogs" debitCreditFlag="D"
                            assetId="55400" acctgTransEntrySeqId="02"/>
                </mantle.ledger.transaction.AcctgTrans>
                <mantle.product.asset.AssetDetail assetDetailId="55706" assetId="55400" productId="DEMO_1_1"
                        assetReservationId="55701" shipmentId="55701" effectiveDate="${effectiveTime}" quantityOnHandDiff="-1"/>
            </mantle.product.issuance.AssetIssuance>
        </entity-facade-xml>""").check()
        logger.info("validate Asset Issuance and Accounting Transactions data check results: ")
        for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)

        then:
        dataCheckErrors.size() == 0
    }
}
