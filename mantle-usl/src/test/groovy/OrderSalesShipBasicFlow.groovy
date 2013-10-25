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

/* To run these make sure moqui, and mantle are in place and run: "gradle cleanAll load runtime/mantle/mantle-usl:test" */
class OrderSalesShipBasicFlow extends Specification {
    @Shared
    protected final static Logger logger = LoggerFactory.getLogger(OrderSalesShipBasicFlow.class)
    @Shared
    ExecutionContext ec
    @Shared
    String cartOrderId = null, orderPartSeqId
    @Shared
    Map setInfoOut

    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        // set an effective date so data check works, etc; Long value (when set from Locale of john.doe, US/Central): 1383411600000
        ec.user.setEffectiveTime(ec.l10n.parseTimestamp("2013-11-02 12:00:00.0", null))

        ec.entity.tempSetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans", 55500, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.shipment.ShipmentItemSource", 55500, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.asset.Asset", 55500, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.issuance.AssetIssuance", 55500, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.invoice.Invoice", 55500, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.order.OrderItemBilling", 55500, 10)
    }

    def cleanupSpec() {
        ec.entity.tempResetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans")
        ec.entity.tempResetSequencedIdPrimary("mantle.shipment.ShipmentItemSource")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.asset.Asset")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.issuance.AssetIssuance")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.invoice.Invoice")
        ec.entity.tempResetSequencedIdPrimary("mantle.order.OrderItemBilling")
        ec.destroy()
    }

    def setup() {
        ec.artifactExecution.disableAuthz()
    }

    def cleanup() {
        ec.artifactExecution.enableAuthz()
    }

    def "create Sales Order"() {
        when:
        ec.user.loginUser("joe@public.com", "moqui", null)

        String productStoreId = "POPC_DEFAULT"
        EntityValue productStore = ec.entity.makeFind("mantle.product.store.ProductStore").condition("productStoreId", productStoreId).one()
        String currencyUomId = productStore.defaultCurrencyUomId
        String priceUomId = productStore.defaultCurrencyUomId
        // String defaultLocale = productStore.defaultLocale
        // String organizationPartyId = productStore.organizationPartyId
        String vendorPartyId = productStore.organizationPartyId
        String customerPartyId = ec.user.userAccount.partyId

        Map priceMap = ec.service.sync().name("mantle.product.ProductServices.get#ProductPrice")
                .parameters([productId:'DEMO_1_1', priceUomId:priceUomId, productStoreId:productStoreId,
                vendorPartyId:vendorPartyId, customerPartyId:customerPartyId]).call()

        Map addOut1 = ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                .parameters([orderId:cartOrderId, productId:'DEMO_1_1', quantity:1, customerPartyId:customerPartyId,
                    currencyUomId:currencyUomId, productStoreId:productStoreId]).call()

        cartOrderId = addOut1.orderId
        orderPartSeqId = addOut1.orderPartSeqId

        Map addOut2 = ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                .parameters([orderId:cartOrderId, productId:'DEMO_3_1', quantity:5, customerPartyId:customerPartyId,
                    currencyUomId:currencyUomId, productStoreId:productStoreId]).call()

        setInfoOut = ec.service.sync().name("mantle.order.OrderServices.set#OrderBillingShippingInfo")
                .parameters([orderId:cartOrderId, paymentMethodId:'CustJqpCc', shippingPostalContactMechId:'CustJqpAddr',
                    shippingTelecomContactMechId:'CustJqpTeln', shipmentMethodEnumId:'ShMthNoShipping']).call()
        ec.service.sync().name("mantle.order.OrderServices.place#Order").parameters([orderId:cartOrderId]).call()

        ec.user.logoutUser()

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.order.OrderHeader orderId="${cartOrderId}" entryDate="1383418800000" placedDate="1383418800000"
                statusId="OrderApproved" currencyUomId="USD" productStoreId="POPC_DEFAULT" grandTotal="55.84"/>

            <mantle.account.payment.Payment paymentId="${setInfoOut.paymentId}" paymentMethodId="CustJqpCc"
                orderId="${cartOrderId}" orderPartSeqId="01" amount="55.84" amountUomId="USD"/>

            <mantle.order.OrderPart orderId="${cartOrderId}" orderPartSeqId="01" vendorPartyId="ORG_BIZI_RETAIL"
                customerPartyId="CustJqp" shipmentMethodEnumId="ShMthNoShipping" postalContactMechId="CustJqpAddr"
                telecomContactMechId="CustJqpTeln" partTotal="55.84"/>
            <mantle.order.OrderItem orderId="${cartOrderId}" orderItemSeqId="01" orderPartSeqId="01" itemTypeEnumId="ItemProduct"
                productId="DEMO_1_1" itemDescription="Demo Product One-One" quantity="1" unitAmount="16.99"
                unitListPrice="16.99" isModifiedPrice="N"/>
            <mantle.order.OrderItem orderId="${cartOrderId}" orderItemSeqId="02" orderPartSeqId="01" itemTypeEnumId="ItemProduct"
                productId="DEMO_3_1" itemDescription="Demo Product Three-One" quantity="5" unitAmount="7.77"
                unitListPrice="7.77" isModifiedPrice="N"/>
        </entity-facade-xml>""").check()
        logger.info("create Sales Order data check results: " + dataCheckErrors)

        then:
        priceMap.price == 16.99
        priceMap.priceUomId == 'USD'
        vendorPartyId == 'ORG_BIZI_RETAIL'
        customerPartyId == 'CustJqp'

        dataCheckErrors.size() == 0
    }

    def "ship Sales Order"() {
        when:
        ec.user.loginUser("john.doe", "moqui", null)

        Map shipResult = ec.service.sync().name("mantle.shipment.ShipmentServices.ship#OrderPart")
                .parameters([orderId:cartOrderId, orderPartSeqId:orderPartSeqId]).call()

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- OrderHeader status to Completed -->
            <mantle.order.OrderHeader orderId="${cartOrderId}" statusId="OrderCompleted"/>

            <!-- Shipment created -->
            <mantle.shipment.Shipment shipmentId="${shipResult.shipmentId}" shipmentTypeEnumId="ShpTpSales"
                statusId="ShipShipped" fromPartyId="ORG_BIZI_RETAIL" toPartyId="CustJqp"/>
            <mantle.shipment.ShipmentPackage shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"/>

            <mantle.shipment.ShipmentItem shipmentId="${shipResult.shipmentId}" productId="DEMO_1_1" quantity="1"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55500" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_1_1" orderId="${cartOrderId}" orderItemSeqId="01" statusId="SisPacked" quantity="1"
                invoiceId="55500" invoiceItemSeqId="01"/>
            <mantle.shipment.ShipmentPackageContent shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                productId="DEMO_1_1" quantity="1"/>

            <mantle.shipment.ShipmentItem shipmentId="${shipResult.shipmentId}" productId="DEMO_3_1" quantity="5"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55501" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_3_1" orderId="${cartOrderId}" orderItemSeqId="02" statusId="SisPacked" quantity="5"
                invoiceId="55500" invoiceItemSeqId="02"/>
            <mantle.shipment.ShipmentPackageContent shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                productId="DEMO_3_1" quantity="5"/>

            <mantle.shipment.ShipmentRouteSegment shipmentId="${shipResult.shipmentId}" shipmentRouteSegmentSeqId="01"
                destPostalContactMechId="CustJqpAddr" destTelecomContactMechId="CustJqpTeln"/>
            <mantle.shipment.ShipmentPackageRouteSeg shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                shipmentRouteSegmentSeqId="01"/>

            <!-- Asset created, issued, changed record in detail -->
            <mantle.product.asset.Asset assetId="55500" assetTypeEnumId="INVENTORY" statusId="AST_AVAILABLE"
                productId="DEMO_1_1" hasQuantity="Y" quantityOnHandTotal="-1" availableToPromiseTotal="-1"
                dateReceived="1383418800000"/>
            <mantle.product.issuance.AssetIssuance assetIssuanceId="55500" assetId="55500" orderId="${cartOrderId}"
                orderItemSeqId="01" shipmentId="${shipResult.shipmentId}" productId="DEMO_1_1" quantity="1"/>
            <mantle.product.asset.AssetDetail assetId="55500" assetDetailSeqId="01" effectiveDate="1383418800000"
                quantityOnHandDiff="-1" availableToPromiseDiff="-1" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_1_1" assetIssuanceId="55500"/>

            <mantle.product.asset.Asset assetId="55501" assetTypeEnumId="INVENTORY" statusId="AST_AVAILABLE"
                productId="DEMO_3_1" hasQuantity="Y" quantityOnHandTotal="-5" availableToPromiseTotal="-5"
                dateReceived="1383418800000"/>
            <mantle.product.issuance.AssetIssuance assetIssuanceId="55501" assetId="55501" orderId="${cartOrderId}"
                orderItemSeqId="02" shipmentId="${shipResult.shipmentId}" productId="DEMO_3_1" quantity="5"/>
            <mantle.product.asset.AssetDetail assetId="55501" assetDetailSeqId="01" effectiveDate="1383418800000"
                quantityOnHandDiff="-5" availableToPromiseDiff="-5" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_3_1" assetIssuanceId="55501"/>

            <!-- Invoice created and Finalized (status set by action in SECA rule) -->
            <mantle.account.invoice.Invoice invoiceId="55500" invoiceTypeEnumId="InvoiceSales"
                fromPartyId="ORG_BIZI_RETAIL" toPartyId="CustJqp" statusId="InvoiceFinalized" invoiceDate="1383418800000"
                description="Invoice for Order ${cartOrderId} part 01 and Shipment ${shipResult.shipmentId}" currencyUomId="USD"/>

            <mantle.account.invoice.InvoiceItem invoiceId="55500" invoiceItemSeqId="01" itemTypeEnumId="ItemProduct"
                productId="DEMO_1_1" quantity="1" amount="16.99" description="Demo Product One-One" itemDate="1383418800000"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55500" orderId="${cartOrderId}" orderItemSeqId="01"
                invoiceId="55500" invoiceItemSeqId="01" assetIssuanceId="55500" shipmentId="${shipResult.shipmentId}"
                quantity="1" amount="16.99"/>

            <mantle.account.invoice.InvoiceItem invoiceId="55500" invoiceItemSeqId="02" itemTypeEnumId="ItemProduct"
                productId="DEMO_3_1" quantity="5" amount="7.77" description="Demo Product Three-One" itemDate="1383418800000"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55501" orderId="${cartOrderId}" orderItemSeqId="02"
                invoiceId="55500" invoiceItemSeqId="02" assetIssuanceId="55501" shipmentId="${shipResult.shipmentId}"
                quantity="5" amount="7.77"/>

            <!-- AcctgTrans created for Finalized Invoice -->
            <mantle.ledger.transaction.AcctgTrans acctgTransId="55500" acctgTransTypeEnumId="AttSalesInvoice"
                organizationPartyId="ORG_BIZI_RETAIL" transactionDate="1383418800000" isPosted="Y"
                postedDate="1383418800000" glFiscalTypeEnumId="GLFT_ACTUAL" amountUomId="USD" otherPartyId="CustJqp"
                invoiceId="55500"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55500" acctgTransEntrySeqId="01" debitCreditFlag="C"
                amount="16.99" glAccountId="401000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"
                productId="DEMO_1_1" invoiceItemSeqId="01"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55500" acctgTransEntrySeqId="02" debitCreditFlag="C"
                amount="38.85" glAccountId="401000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"
                productId="DEMO_3_1" invoiceItemSeqId="02"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55500" acctgTransEntrySeqId="03" debitCreditFlag="D"
                amount="55.84" glAccountTypeEnumId="ACCOUNTS_RECEIVABLE" glAccountId="120000"
                reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"/>
        </entity-facade-xml>""").check()
        logger.info("ship Sales Order data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }
}
