/*
 * This Work is in the public domain and is provided on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
 * including, without limitation, any warranties or conditions of TITLE,
 * NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.
 * You are solely responsible for determining the appropriateness of using
 * this Work and assume any risks associated with your use of this Work.
 *
 * This Work includes contributions authored by David E. Jones, not as a
 * "work for hire", who hereby disclaims any copyright to the same.
 */

import org.moqui.Moqui
import org.moqui.context.ExecutionContext
import org.moqui.entity.EntityValue
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import spock.lang.Shared
import spock.lang.Specification

/* To run these make sure moqui, and mantle are in place and run:
    "gradle cleanAll load runtime/mantle/mantle-usl:test"
   Or to quick run with saved DB copy use "gradle loadSave" once then each time "gradle reloadSave runtime/mantle/mantle-usl:test"
 */
class OrderPurchaseReceiveBasicFlow extends Specification {
    @Shared
    protected final static Logger logger = LoggerFactory.getLogger(OrderPurchaseReceiveBasicFlow.class)
    @Shared
    ExecutionContext ec
    @Shared
    String purchaseOrderId = null, orderPartSeqId
    @Shared
    Map setInfoOut, invResult
    @Shared
    String vendorPartyId = 'MiddlemanInc', customerPartyId = 'ORG_BIZI_RETAIL', priceUomId = 'USD', currencyUomId = 'USD'


    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        ec.user.loginUser("john.doe", "moqui", null)
        // set an effective date so data check works, etc; Long value (when set from Locale of john.doe, US/Central, '2013-11-02 12:00:00.0'): 1383411600000
        ec.user.setEffectiveTime(ec.l10n.parseTimestamp("1383411600000", null))

        ec.entity.tempSetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.shipment.ShipmentItemSource", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.asset.Asset", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.invoice.Invoice", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.payment.PaymentApplication", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.order.OrderItemBilling", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("moqui.entity.EntityAuditLog", 55400, 100)
        // TODO: add EntityAuditLog validation (especially status changes, etc)
    }

    def cleanupSpec() {
        ec.entity.tempResetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans")
        ec.entity.tempResetSequencedIdPrimary("mantle.shipment.ShipmentItemSource")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.asset.Asset")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.invoice.Invoice")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.payment.PaymentApplication")
        ec.entity.tempResetSequencedIdPrimary("mantle.order.OrderItemBilling")
        ec.entity.tempResetSequencedIdPrimary("moqui.entity.EntityAuditLog")
        ec.destroy()
    }

    def setup() {
        ec.artifactExecution.disableAuthz()
    }

    def cleanup() {
        ec.artifactExecution.enableAuthz()
    }

    def "create Purchase Order"() {
        when:
        Map priceMap = ec.service.sync().name("mantle.product.ProductServices.get#ProductPrice")
                .parameters([productId:'DEMO_1_1', priceUomId:priceUomId, quantity:1,
                    vendorPartyId:vendorPartyId, customerPartyId:customerPartyId]).call()
        Map priceMap2 = ec.service.sync().name("mantle.product.ProductServices.get#ProductPrice")
                .parameters([productId:'DEMO_1_1', priceUomId:priceUomId, quantity:100,
                    vendorPartyId:vendorPartyId, customerPartyId:customerPartyId]).call()

        // no store, etc for purchase orders so explicitly create order and set parties
        Map orderOut = ec.service.sync().name("mantle.order.OrderServices.create#Order")
                .parameters([customerPartyId:customerPartyId, vendorPartyId:vendorPartyId, currencyUomId:currencyUomId])
                .call()

        purchaseOrderId = orderOut.orderId
        orderPartSeqId = orderOut.orderPartSeqId

        Map addOut1 = ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId, productId:'DEMO_1_1', quantity:150])
                .call()
        Map addOut2 = ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId, productId:'DEMO_3_1', quantity:100])
                .call()

        setInfoOut = ec.service.sync().name("mantle.order.OrderServices.set#OrderBillingShippingInfo")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId,
                    paymentMethodTypeEnumId:'PmtCompanyCheck', shippingPostalContactMechId:'ORG_BIZI_RTL_SA',
                    shippingTelecomContactMechId:'ORG_BIZI_RTL_PT', shipmentMethodEnumId:'ShMthNoShipping']).call()

        // one person will place the PO
        ec.service.sync().name("mantle.order.OrderServices.place#Order").parameters([orderId:purchaseOrderId]).call()
        // typically another person will approve the PO
        ec.service.sync().name("mantle.order.OrderServices.approve#Order").parameters([orderId:purchaseOrderId]).call()
        // then the PO is sent to the vendor/supplier

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.order.OrderHeader orderId="${purchaseOrderId}" entryDate="1383411600000" placedDate="1383411600000"
                statusId="OrderApproved" currencyUomId="USD" grandTotal=""/>

            <mantle.account.payment.Payment paymentId="${setInfoOut.paymentId}"
                paymentMethodTypeEnumId="PmtCompanyCheck" orderId="${purchaseOrderId}" orderPartSeqId="01"
                statusId="PmntPromised" amount="" amountUomId="USD"/>

            <mantle.order.OrderPart orderId="${purchaseOrderId}" orderPartSeqId="01" vendorPartyId="MiddlemanInc"
                customerPartyId="ORG_BIZI_RETAIL" shipmentMethodEnumId="ShMthNoShipping" postalContactMechId="ORG_BIZI_RTL_SA"
                telecomContactMechId="ORG_BIZI_RTL_PT" partTotal=""/>
            <mantle.order.OrderItem orderId="${purchaseOrderId}" orderItemSeqId="01" orderPartSeqId="01" itemTypeEnumId="ItemProduct"
                productId="DEMO_1_1" itemDescription="Demo Product One-One" quantity="150" unitAmount="8.00"
                isModifiedPrice="N"/>
            <mantle.order.OrderItem orderId="${purchaseOrderId}" orderItemSeqId="02" orderPartSeqId="01" itemTypeEnumId="ItemProduct"
                productId="DEMO_3_1" itemDescription="Demo Product Three-One" quantity="100" unitAmount="4.50"
                isModifiedPrice="N"/>
        </entity-facade-xml>""").check()
        logger.info("create Purchase Order data check results: " + dataCheckErrors)

        then:
        priceMap.price == 9.00
        priceMap2.price == 8.00
        priceMap.priceUomId == 'USD'
        vendorPartyId == 'MiddlemanInc'
        customerPartyId == 'ORG_BIZI_RETAIL'

        dataCheckErrors.size() == 0
    }

    def "process Purchase Invoice"() {
        when:
        // NOTE: in real-world scenarios the invoice received may not match what is expected, may be for multiple or
        //     partial purchase orders, etc; for this we'll simply create an invoice automatically from the Order
        // to somewhat simulate real-world, create in InvoiceIncoming then change to InvoiceReceived to allow for manual
        //     changes between

        invResult = ec.service.sync().name("mantle.account.InvoiceServices.create#EntireOrderPartInvoice")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId]).call()

        ec.service.sync().name("update#mantle.account.invoice.Invoice")
                .parameters([invoiceId:invResult.invoiceId, statusId:'InvoiceReceived']).call()
        
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- Invoice created and received, not yet approved/etc -->
            <mantle.account.invoice.Invoice invoiceId="${invResult.invoiceId}" invoiceTypeEnumId="InvoiceSales" fromPartyId="MiddlemanInc"
                toPartyId="ORG_BIZI_RETAIL" statusId="InvoiceReceived" invoiceDate="1383411600000"
                description="Invoice for Order ${purchaseOrderId} part 01" currencyUomId="USD"/>

            <mantle.account.invoice.InvoiceItem invoiceId="${invResult.invoiceId}" invoiceItemSeqId="01" itemTypeEnumId="ItemProduct"
                productId="DEMO_1_1" quantity="150" amount="8.00" description="Demo Product One-One" itemDate="1383411600000"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55400" orderId="${purchaseOrderId}" orderItemSeqId="01"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="01" quantity="150" amount="8.00"/>

            <mantle.account.invoice.InvoiceItem invoiceId="${invResult.invoiceId}" invoiceItemSeqId="02" itemTypeEnumId="ItemProduct"
                productId="DEMO_3_1" quantity="100" amount="4.50" description="Demo Product Three-One" itemDate="1383411600000"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55401" orderId="${purchaseOrderId}" orderItemSeqId="02"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="02" quantity="100" amount="4.50"/>

        </entity-facade-xml>""").check()
        logger.info("validate Shipment Invoice data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    /*
    def "receive Purchase Order"() {
        when:
        shipResult = ec.service.sync().name("mantle.shipment.ShipmentServices.ship#OrderPart")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId]).call()

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- Shipment created -->
            <mantle.shipment.Shipment shipmentId="${shipResult.shipmentId}" shipmentTypeEnumId="ShpTpSales"
                statusId="ShipShipped" fromPartyId="ORG_BIZI_RETAIL" toPartyId="CustJqp"/>
            <mantle.shipment.ShipmentPackage shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"/>

            <mantle.shipment.ShipmentItem shipmentId="${shipResult.shipmentId}" productId="DEMO_1_1" quantity="1"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55400" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_1_1" orderId="${purchaseOrderId}" orderItemSeqId="01" statusId="SisPacked" quantity="1"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="01"/>
            <mantle.shipment.ShipmentPackageContent shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                productId="DEMO_1_1" quantity="1"/>

            <mantle.shipment.ShipmentItem shipmentId="${shipResult.shipmentId}" productId="DEMO_3_1" quantity="5"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55401" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_3_1" orderId="${purchaseOrderId}" orderItemSeqId="02" statusId="SisPacked" quantity="5"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="02"/>
            <mantle.shipment.ShipmentPackageContent shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                productId="DEMO_3_1" quantity="5"/>

            <mantle.shipment.ShipmentItem shipmentId="${shipResult.shipmentId}" productId="DEMO_2_1" quantity="7"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55402" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_2_1" orderId="${purchaseOrderId}" orderItemSeqId="03" statusId="SisPacked" quantity="7"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="03"/>
            <mantle.shipment.ShipmentPackageContent shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                productId="DEMO_2_1" quantity="7"/>

            <mantle.shipment.ShipmentRouteSegment shipmentId="${shipResult.shipmentId}" shipmentRouteSegmentSeqId="01"
                destPostalContactMechId="CustJqpAddr" destTelecomContactMechId="CustJqpTeln"/>
            <mantle.shipment.ShipmentPackageRouteSeg shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                shipmentRouteSegmentSeqId="01"/>
        </entity-facade-xml>""").check()
        logger.info("receive Purchase Order data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Purchase Order Complete"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- OrderHeader status to Completed -->
            <mantle.order.OrderHeader orderId="${purchaseOrderId}" statusId="OrderCompleted"/>
        </entity-facade-xml>""").check()
        logger.info("validate Purchase Order Complete data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Assets Received"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- Asset created, issued, changed record in detail -->

            <mantle.product.asset.Asset assetId="DEMO_1_1A" quantityOnHandTotal="99" availableToPromiseTotal="99"/>
            <mantle.product.issuance.AssetIssuance assetIssuanceId="55400" assetId="DEMO_1_1A" assetReservationId="55400"
                orderId="${purchaseOrderId}" orderItemSeqId="01" shipmentId="${shipResult.shipmentId}" productId="DEMO_1_1"
                quantity="1"/>
            <mantle.product.asset.AssetDetail assetId="DEMO_1_1A" assetDetailSeqId="03" effectiveDate="1383411600000"
                quantityOnHandDiff="-1" assetReservationId="55400" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_1_1" assetIssuanceId="55400"/>

            <mantle.product.asset.Asset assetId="DEMO_3_1A" quantityOnHandTotal="0" availableToPromiseTotal="0"/>
            <mantle.product.issuance.AssetIssuance assetIssuanceId="55401" assetId="DEMO_3_1A" assetReservationId="55401"
                orderId="${purchaseOrderId}" orderItemSeqId="02" shipmentId="${shipResult.shipmentId}" productId="DEMO_3_1"
                quantity="5"/>
            <mantle.product.asset.AssetDetail assetId="DEMO_3_1A" assetDetailSeqId="03" effectiveDate="1383411600000"
                quantityOnHandDiff="-5" assetReservationId="55401" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_3_1" assetIssuanceId="55401"/>

            <!-- this is an auto-created Asset based on the inventory issuance -->
            <mantle.product.asset.Asset assetId="55400" quantityOnHandTotal="-7" availableToPromiseTotal="-7"/>
            <mantle.product.issuance.AssetIssuance assetIssuanceId="55402" assetId="55400" assetReservationId="55402"
                orderId="${purchaseOrderId}" orderItemSeqId="03" shipmentId="${shipResult.shipmentId}" productId="DEMO_2_1"
                quantity="7"/>
            <mantle.product.asset.AssetDetail assetId="55400" assetDetailSeqId="02" effectiveDate="1383411600000"
                quantityOnHandDiff="-7" assetReservationId="55402" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_2_1" assetIssuanceId="55402"/>
        </entity-facade-xml>""").check()
        logger.info("validate Assets Received data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "approve and Pay Purchase Invoice"() {
        when:
        // TODO: approve Invoice from Vendor
        // TODO: record Payment for Invoice

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- Invoice created and Finalized (status set by action in SECA rule) -->
            <mantle.account.invoice.Invoice invoiceId="${invResult.invoiceId}" statusId="InvoicePmtRecvd"/>

            <mantle.account.payment.PaymentApplication paymentApplicationId="55400" paymentId="${setInfoOut.paymentId}"
                invoiceId="${invResult.invoiceId}" amountApplied="140.68" appliedDate="1383411600000"/>

            <mantle.account.payment.Payment paymentId="${setInfoOut.paymentId}" statusId="PmntDelivered"/>
        </entity-facade-xml>""").check()
        logger.info("validate Shipment Invoice data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Purchase Invoice Accounting Transaction"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- AcctgTrans created for Finalized Invoice -->
            <mantle.ledger.transaction.AcctgTrans acctgTransId="55400" acctgTransTypeEnumId="AttSalesInvoice"
                organizationPartyId="ORG_BIZI_RETAIL" transactionDate="1383411600000" isPosted="Y"
                postedDate="1383411600000" glFiscalTypeEnumId="GLFT_ACTUAL" amountUomId="USD" otherPartyId="CustJqp"
                invoiceId="${invResult.invoiceId}"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55400" acctgTransEntrySeqId="01" debitCreditFlag="C"
                amount="16.99" glAccountId="401000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"
                productId="DEMO_1_1" invoiceItemSeqId="01"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55400" acctgTransEntrySeqId="02" debitCreditFlag="C"
                amount="38.85" glAccountId="401000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"
                productId="DEMO_3_1" invoiceItemSeqId="02"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55400" acctgTransEntrySeqId="03" debitCreditFlag="C"
                amount="84.84" glAccountId="401000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"
                productId="DEMO_2_1" invoiceItemSeqId="03"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55400" acctgTransEntrySeqId="04" debitCreditFlag="D"
                amount="140.68" glAccountTypeEnumId="ACCOUNTS_RECEIVABLE" glAccountId="120000"
                reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"/>
        </entity-facade-xml>""").check()
        logger.info("validate Shipment Invoice Accounting Transaction data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }
    */
}