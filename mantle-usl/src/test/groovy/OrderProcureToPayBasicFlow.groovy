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
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import spock.lang.Shared
import spock.lang.Specification

import java.sql.Timestamp

/* To run these make sure moqui, and mantle are in place and run:
    "gradle cleanAll load runtime/mantle/mantle-usl:test"
   Or to quick run with saved DB copy use "gradle loadSave" once then each time "gradle reloadSave runtime/mantle/mantle-usl:test"
 */
class OrderProcureToPayBasicFlow extends Specification {
    @Shared
    protected final static Logger logger = LoggerFactory.getLogger(OrderProcureToPayBasicFlow.class)
    @Shared
    ExecutionContext ec
    @Shared
    String purchaseOrderId = null, orderPartSeqId
    @Shared
    Map setInfoOut, invResult, shipResult, sendPmtResult
    @Shared
    String vendorPartyId = 'MiddlemanInc', customerPartyId = 'ORG_BIZI_RETAIL'
    @Shared
    String priceUomId = 'USD', currencyUomId = 'USD'
    @Shared
    String facilityId = 'ORG_BIZI_RETAIL_WH'
    @Shared
    long effectiveTime = System.currentTimeMillis()


    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        ec.user.loginUser("john.doe", "moqui", null)
        // set an effective date so data check works, etc
        ec.user.setEffectiveTime(new Timestamp(effectiveTime))

        ec.entity.tempSetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.shipment.ShipmentItemSource", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.asset.Asset", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.asset.AssetDetail", 55400, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.receipt.AssetReceipt", 55400, 10)
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
        ec.entity.tempResetSequencedIdPrimary("mantle.product.asset.AssetDetail")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.receipt.AssetReceipt")
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
        Map priceMap = ec.service.sync().name("mantle.product.PriceServices.get#ProductPrice")
                .parameters([productId:'DEMO_1_1', priceUomId:priceUomId, quantity:1,
                    vendorPartyId:vendorPartyId, customerPartyId:customerPartyId]).call()
        Map priceMap2 = ec.service.sync().name("mantle.product.PriceServices.get#ProductPrice")
                .parameters([productId:'DEMO_1_1', priceUomId:priceUomId, quantity:100,
                    vendorPartyId:vendorPartyId, customerPartyId:customerPartyId]).call()

        // no store, etc for purchase orders so explicitly create order and set parties
        Map orderOut = ec.service.sync().name("mantle.order.OrderServices.create#Order")
                .parameters([customerPartyId:customerPartyId, vendorPartyId:vendorPartyId, currencyUomId:currencyUomId])
                .call()

        purchaseOrderId = orderOut.orderId
        orderPartSeqId = orderOut.orderPartSeqId

        ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId, productId:'DEMO_1_1', quantity:150,
                    itemTypeEnumId:'ItemInventory']).call()
        ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId, productId:'DEMO_3_1', quantity:100,
                    itemTypeEnumId:'ItemInventory']).call()
        ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId, productId:'EQUIP_1', quantity:1,
                    itemTypeEnumId:'ItemAssetEquipment', unitAmount:10000]).call()

        // add shipping charge
        ec.service.sync().name("mantle.order.OrderServices.create#OrderItem")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId, unitAmount:145.00,
                    itemTypeEnumId:'ItemShipping', itemDescription:'Incoming Freight']).call()

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
            <mantle.order.OrderHeader orderId="${purchaseOrderId}" entryDate="${effectiveTime}" placedDate="${effectiveTime}"
                statusId="OrderApproved" currencyUomId="USD" grandTotal="11795.00"/>

            <mantle.account.payment.Payment paymentId="${setInfoOut.paymentId}" fromPartyId="${customerPartyId}" toPartyId="${vendorPartyId}"
                paymentMethodTypeEnumId="PmtCompanyCheck" orderId="${purchaseOrderId}" orderPartSeqId="01"
                statusId="PmntPromised" amount="11795.00" amountUomId="USD"/>

            <mantle.order.OrderPart orderId="${purchaseOrderId}" orderPartSeqId="01" vendorPartyId="${vendorPartyId}"
                customerPartyId="${customerPartyId}" shipmentMethodEnumId="ShMthNoShipping" postalContactMechId="ORG_BIZI_RTL_SA"
                telecomContactMechId="ORG_BIZI_RTL_PT" partTotal=""/>
            <mantle.order.OrderItem orderId="${purchaseOrderId}" orderItemSeqId="01" orderPartSeqId="01" itemTypeEnumId="ItemInventory"
                productId="DEMO_1_1" itemDescription="Demo Product One-One" quantity="150" unitAmount="8.00" isModifiedPrice="N"/>
            <mantle.order.OrderItem orderId="${purchaseOrderId}" orderItemSeqId="02" orderPartSeqId="01" itemTypeEnumId="ItemInventory"
                productId="DEMO_3_1" itemDescription="Demo Product Three-One" quantity="100" unitAmount="4.50" isModifiedPrice="N"/>
            <mantle.order.OrderItem orderId="${purchaseOrderId}" orderItemSeqId="03" orderPartSeqId="01" itemTypeEnumId="ItemAssetEquipment"
                productId="EQUIP_1" itemDescription="Picker Bot 2000" quantity="1" unitAmount="10000" isModifiedPrice="Y"/>
            <mantle.order.OrderItem orderId="${purchaseOrderId}" orderItemSeqId="04" orderPartSeqId="01" itemTypeEnumId="ItemShipping"
                itemDescription="Incoming Freight" quantity="1" unitAmount="145.00"/>
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

    def "create Purchase Order Shipment and Schedule"() {
        when:
        shipResult = ec.service.sync().name("mantle.shipment.ShipmentServices.create#OrderPartShipment")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId, destinationFacilityId:facilityId]).call()

        // TODO: add PO Shipment Schedule, update status to ShipScheduled

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- Shipment created -->
            <mantle.shipment.Shipment shipmentId="${shipResult.shipmentId}" shipmentTypeEnumId="ShpTpPurchase"
                statusId="ShipInput" fromPartyId="MiddlemanInc" toPartyId="ORG_BIZI_RETAIL"/>
            <mantle.shipment.ShipmentPackage shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"/>

            <mantle.shipment.ShipmentItem shipmentId="${shipResult.shipmentId}" productId="DEMO_1_1" quantity="150"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55400" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_1_1" orderId="${purchaseOrderId}" orderItemSeqId="01" statusId="SisPending"
                quantity="150" quantityNotHandled="150" invoiceId="" invoiceItemSeqId=""/>

            <mantle.shipment.ShipmentItem shipmentId="${shipResult.shipmentId}" productId="DEMO_3_1" quantity="100"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55401" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_3_1" orderId="${purchaseOrderId}" orderItemSeqId="02" statusId="SisPending"
                quantity="100" quantityNotHandled="100" invoiceId="" invoiceItemSeqId=""/>

            <mantle.shipment.ShipmentItem shipmentId="${shipResult.shipmentId}" productId="EQUIP_1" quantity="1"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55402" shipmentId="${shipResult.shipmentId}"
                productId="EQUIP_1" orderId="${purchaseOrderId}" orderItemSeqId="03" statusId="SisPending" quantity="1"
                quantityNotHandled="1" invoiceId="" invoiceItemSeqId=""/>

            <!-- no SPC when not outgoing packed, can be added by something else though:
            <mantle.shipment.ShipmentPackageContent shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                productId="DEMO_1_1" quantity="150"/>
            <mantle.shipment.ShipmentPackageContent shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                productId="DEMO_3_1" quantity="100"/>
            -->

            <mantle.shipment.ShipmentRouteSegment shipmentId="${shipResult.shipmentId}" shipmentRouteSegmentSeqId="01"
                destPostalContactMechId="ORG_BIZI_RTL_SA" destTelecomContactMechId="ORG_BIZI_RTL_PT"/>
            <mantle.shipment.ShipmentPackageRouteSeg shipmentId="${shipResult.shipmentId}" shipmentPackageSeqId="01"
                shipmentRouteSegmentSeqId="01"/>
        </entity-facade-xml>""").check()
        logger.info("receive Purchase Order data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "process Purchase Invoice"() {
        when:
        // NOTE: in real-world scenarios the invoice received may not match what is expected, may be for multiple or
        //     partial purchase orders, etc; for this we'll simply create an invoice automatically from the Order
        // to somewhat simulate real-world, create in InvoiceIncoming then change to InvoiceReceived to allow for manual
        //     changes between

        // set Shipment Shipped
        ec.service.sync().name("mantle.shipment.ShipmentServices.ship#Shipment")
                .parameters([shipmentId:shipResult.shipmentId]).call()

        invResult = ec.service.sync().name("mantle.account.InvoiceServices.create#EntireOrderPartInvoice")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId, statusId:'InvoiceReceived']).call()

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- Shipment to Shipped status -->
            <mantle.shipment.Shipment shipmentId="${shipResult.shipmentId}" shipmentTypeEnumId="ShpTpPurchase"
                statusId="ShipShipped" fromPartyId="MiddlemanInc" toPartyId="ORG_BIZI_RETAIL"/>

            <!-- Invoice created and received, not yet approved/etc -->
            <mantle.account.invoice.Invoice invoiceId="${invResult.invoiceId}" invoiceTypeEnumId="InvoiceSales"
                fromPartyId="MiddlemanInc" toPartyId="ORG_BIZI_RETAIL" statusId="InvoiceReceived"
                invoiceDate="${effectiveTime}" description="Invoice for Order ${purchaseOrderId} part 01"
                currencyUomId="USD"/>

            <mantle.account.invoice.InvoiceItem invoiceId="${invResult.invoiceId}" invoiceItemSeqId="01"
                itemTypeEnumId="ItemInventory" productId="DEMO_1_1" quantity="150" amount="8.00"
                description="Demo Product One-One" itemDate="${effectiveTime}"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55400" orderId="${purchaseOrderId}" orderItemSeqId="01"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="01" quantity="150" amount="8.00"
                shipmentId="${shipResult.shipmentId}"/>

            <mantle.account.invoice.InvoiceItem invoiceId="${invResult.invoiceId}" invoiceItemSeqId="02"
                itemTypeEnumId="ItemInventory" productId="DEMO_3_1" quantity="100" amount="4.50"
                description="Demo Product Three-One" itemDate="${effectiveTime}"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55401" orderId="${purchaseOrderId}" orderItemSeqId="02"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="02" quantity="100" amount="4.50"
                shipmentId="${shipResult.shipmentId}"/>

            <mantle.account.invoice.InvoiceItem invoiceId="${invResult.invoiceId}" invoiceItemSeqId="03"
                itemTypeEnumId="ItemAssetEquipment" productId="EQUIP_1" quantity="1" amount="10,000" description="Picker Bot 2000"
                itemDate="${effectiveTime}"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55402" orderId="${purchaseOrderId}" orderItemSeqId="03"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="03" quantity="1" amount="10,000"
                shipmentId="${shipResult.shipmentId}"/>

            <mantle.account.invoice.InvoiceItem invoiceId="${invResult.invoiceId}" invoiceItemSeqId="04"
                itemTypeEnumId="ItemShipping" quantity="1" amount="145" description="Incoming Freight"
                itemDate="${effectiveTime}"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55403" orderId="${purchaseOrderId}" orderItemSeqId="04"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="04" quantity="1" amount="145"/>

            <!-- ShipmentItemSource now has invoiceId and invoiceItemSeqId -->
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55400" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_1_1" orderId="${purchaseOrderId}" orderItemSeqId="01" statusId="SisPending" quantity="150"
                quantityNotHandled="150" invoiceId="${invResult.invoiceId}" invoiceItemSeqId="01"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55401" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_3_1" orderId="${purchaseOrderId}" orderItemSeqId="02" statusId="SisPending" quantity="100"
                quantityNotHandled="100" invoiceId="${invResult.invoiceId}" invoiceItemSeqId="02"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55402" shipmentId="${shipResult.shipmentId}"
                productId="EQUIP_1" orderId="${purchaseOrderId}" orderItemSeqId="03" statusId="SisPending" quantity="1"
                quantityNotHandled="1" invoiceId="${invResult.invoiceId}" invoiceItemSeqId="03"/>
        </entity-facade-xml>""").check()
        logger.info("validate Shipment Invoice data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "receive Purchase Order Shipment"() {
        when:
        // receive the Shipment, create AssetReceipt records, status to ShipDelivered

        // don't want to receive entire order because need to set parameters for equipment product:
        // ec.service.sync().name("mantle.shipment.ShipmentServices.receive#EntireShipment")
        //         .parameters([shipmentId:shipResult.shipmentId]).call()

        ec.service.sync().name("mantle.shipment.ShipmentServices.receive#ShipmentProduct")
                .parameters([shipmentId:shipResult.shipmentId, productId:'DEMO_1_1',
                    quantityAccepted:150, facilityId:facilityId]).call()
        ec.service.sync().name("mantle.shipment.ShipmentServices.receive#ShipmentProduct")
                .parameters([shipmentId:shipResult.shipmentId, productId:'DEMO_3_1',
                    quantityAccepted:100, facilityId:facilityId]).call()
        ec.service.sync().name("mantle.shipment.ShipmentServices.receive#ShipmentProduct")
                .parameters([shipmentId:shipResult.shipmentId, productId:'EQUIP_1',
                    quantityAccepted:1, facilityId:facilityId, serialNumber:'PB2000AZQRTFP',
                    assetTypeEnumId:'AstTpEquipment']).call()

        ec.service.sync().name("update#mantle.shipment.Shipment")
                .parameters([shipmentId:shipResult.shipmentId, statusId:'ShipDelivered']).call()


        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.shipment.Shipment shipmentId="${shipResult.shipmentId}" shipmentTypeEnumId="ShpTpPurchase"
                statusId="ShipDelivered" fromPartyId="MiddlemanInc" toPartyId="ORG_BIZI_RETAIL"/>
        </entity-facade-xml>""").check()
        logger.info("receive Purchase Order data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "complete Purchase Order"() {
        when:
        // after Shipment Delivered mark Order as Completed
        ec.service.sync().name("mantle.order.OrderServices.complete#OrderPart")
                .parameters([orderId:purchaseOrderId, orderPartSeqId:orderPartSeqId]).call()

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
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.product.asset.Asset assetId="55400" assetTypeEnumId="AstTpInventory" statusId="AstAvailable"
                ownerPartyId="ORG_BIZI_RETAIL" productId="DEMO_1_1" hasQuantity="Y" quantityOnHandTotal="150"
                availableToPromiseTotal="150" assetName="Demo Product One-One" receivedDate="${effectiveTime}"
                acquiredDate="${effectiveTime}" facilityId="ORG_BIZI_RETAIL_WH" acquireOrderId="${purchaseOrderId}"
                acquireOrderItemSeqId="01" acquireCost="8" acquireCostUomId="USD"/>
            <mantle.product.receipt.AssetReceipt assetReceiptId="55400" assetId="55400" productId="DEMO_1_1"
                orderId="${purchaseOrderId}" orderItemSeqId="01" shipmentId="${shipResult.shipmentId}"
                receivedByUserId="EX_JOHN_DOE" receivedDate="${effectiveTime}" quantityAccepted="150"/>
            <mantle.product.asset.AssetDetail assetDetailId="55400" assetId="55400" effectiveDate="${effectiveTime}"
                quantityOnHandDiff="150" availableToPromiseDiff="150" unitCost="8" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_1_1" assetReceiptId="55400"/>

            <mantle.product.asset.Asset assetId="55401" assetTypeEnumId="AstTpInventory" statusId="AstAvailable"
                ownerPartyId="ORG_BIZI_RETAIL" productId="DEMO_3_1" hasQuantity="Y" quantityOnHandTotal="100"
                availableToPromiseTotal="100" assetName="Demo Product Three-One" receivedDate="${effectiveTime}"
                acquiredDate="${effectiveTime}" facilityId="ORG_BIZI_RETAIL_WH" acquireOrderId="${purchaseOrderId}"
                acquireOrderItemSeqId="02" acquireCost="4.5" acquireCostUomId="USD"/>
            <mantle.product.receipt.AssetReceipt assetReceiptId="55401" assetId="55401" productId="DEMO_3_1"
                orderId="${purchaseOrderId}" orderItemSeqId="02" shipmentId="${shipResult.shipmentId}"
                receivedByUserId="EX_JOHN_DOE" receivedDate="${effectiveTime}" quantityAccepted="100"/>
            <mantle.product.asset.AssetDetail assetDetailId="55401" assetId="55401" effectiveDate="${effectiveTime}"
                quantityOnHandDiff="100" availableToPromiseDiff="100" unitCost="4.5" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_3_1" assetReceiptId="55401"/>

            <mantle.product.asset.Asset assetId="55402" assetTypeEnumId="AstTpEquipment" statusId="AstInStorage"
                ownerPartyId="ORG_BIZI_RETAIL" productId="EQUIP_1" hasQuantity="N" quantityOnHandTotal="1"
                availableToPromiseTotal="0" assetName="Picker Bot 2000" serialNumber="PB2000AZQRTFP"
                receivedDate="${effectiveTime}" acquiredDate="${effectiveTime}" facilityId="ORG_BIZI_RETAIL_WH"
                acquireOrderId="${purchaseOrderId}" acquireOrderItemSeqId="03" acquireCost="10,000" acquireCostUomId="USD"/>
            <mantle.product.receipt.AssetReceipt assetReceiptId="55402" assetId="55402" productId="EQUIP_1"
                orderId="${purchaseOrderId}" orderItemSeqId="03" shipmentId="${shipResult.shipmentId}"
                receivedByUserId="EX_JOHN_DOE" receivedDate="${effectiveTime}" quantityAccepted="1"/>
            <mantle.product.asset.AssetDetail assetDetailId="55402" assetId="55402" effectiveDate="${effectiveTime}"
                quantityOnHandDiff="1" availableToPromiseDiff="0" unitCost="10,000" shipmentId="${shipResult.shipmentId}"
                productId="EQUIP_1" assetReceiptId="55402"/>

            <!-- verify assetReceiptId set on OrderItemBilling, and that all else is the same -->
            <mantle.order.OrderItemBilling orderItemBillingId="55400" orderId="${purchaseOrderId}" orderItemSeqId="01"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="01" quantity="150" amount="8.00"
                shipmentId="${shipResult.shipmentId}" assetReceiptId="55400"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55401" orderId="${purchaseOrderId}" orderItemSeqId="02"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="02" quantity="100" amount="4.50"
                shipmentId="${shipResult.shipmentId}" assetReceiptId="55401"/>
            <mantle.order.OrderItemBilling orderItemBillingId="55402" orderId="${purchaseOrderId}" orderItemSeqId="03"
                invoiceId="${invResult.invoiceId}" invoiceItemSeqId="03" quantity="1" amount="10,000"
                shipmentId="${shipResult.shipmentId}" assetReceiptId="55402"/>

            <!-- ShipmentItemSource now has quantityNotHandled="0" and statusId to SisReceived -->
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55400" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_1_1" orderId="${purchaseOrderId}" orderItemSeqId="01" statusId="SisReceived" quantity="150"
                quantityNotHandled="0" invoiceId="${invResult.invoiceId}" invoiceItemSeqId="01"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55401" shipmentId="${shipResult.shipmentId}"
                productId="DEMO_3_1" orderId="${purchaseOrderId}" orderItemSeqId="02" statusId="SisReceived" quantity="100"
                quantityNotHandled="0" invoiceId="${invResult.invoiceId}" invoiceItemSeqId="02"/>
            <mantle.shipment.ShipmentItemSource shipmentItemSourceId="55402" shipmentId="${shipResult.shipmentId}"
                productId="EQUIP_1" orderId="${purchaseOrderId}" orderItemSeqId="03" statusId="SisReceived" quantity="1"
                quantityNotHandled="0" invoiceId="${invResult.invoiceId}" invoiceItemSeqId="03"/>
        </entity-facade-xml>""").check()
        logger.info("validate Assets Received data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }


    def "validate Assets Receipt Accounting Transactions"() {
        when:
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.ledger.transaction.AcctgTrans acctgTransId="55400" acctgTransTypeEnumId="AttInventoryReceipt"
                organizationPartyId="ORG_BIZI_RETAIL" transactionDate="${effectiveTime}" isPosted="Y"
                postedDate="${effectiveTime}" glFiscalTypeEnumId="GLFT_ACTUAL" amountUomId="USD" assetId="55400"
                assetReceiptId="55400"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55400" acctgTransEntrySeqId="01" debitCreditFlag="C"
                amount="1,200" glAccountTypeEnumId="COGS_ACCOUNT" glAccountId="501000"
                reconcileStatusId="AES_NOT_RECONCILED" isSummary="N" productId="DEMO_1_1"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55400" acctgTransEntrySeqId="02" debitCreditFlag="D"
                amount="1,200" glAccountTypeEnumId="INVENTORY_ACCOUNT" glAccountId="140000"
                reconcileStatusId="AES_NOT_RECONCILED" isSummary="N" productId="DEMO_1_1"/>

            <mantle.ledger.transaction.AcctgTrans acctgTransId="55401" acctgTransTypeEnumId="AttInventoryReceipt"
                organizationPartyId="ORG_BIZI_RETAIL" transactionDate="${effectiveTime}" isPosted="Y"
                postedDate="${effectiveTime}" glFiscalTypeEnumId="GLFT_ACTUAL" amountUomId="USD" assetId="55401"
                assetReceiptId="55401"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55401" acctgTransEntrySeqId="01" debitCreditFlag="C"
                amount="450" glAccountTypeEnumId="COGS_ACCOUNT" glAccountId="501000"
                reconcileStatusId="AES_NOT_RECONCILED" isSummary="N" productId="DEMO_3_1"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55401" acctgTransEntrySeqId="02" debitCreditFlag="D"
                amount="450" glAccountTypeEnumId="INVENTORY_ACCOUNT" glAccountId="140000"
                reconcileStatusId="AES_NOT_RECONCILED" isSummary="N" productId="DEMO_3_1"/>

            <!-- NOTE: no inventory transaction for an Equipment Asset -->

        </entity-facade-xml>""").check()
        logger.info("validate Assets Received data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "approve Purchase Invoice"() {
        when:
        // approve Invoice from Vendor (will trigger GL posting)
        ec.service.sync().name("update#mantle.account.invoice.Invoice")
                .parameters([invoiceId:invResult.invoiceId, statusId:'InvoiceApproved']).call()

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.account.invoice.Invoice invoiceId="${invResult.invoiceId}" statusId="InvoiceApproved"/>
        </entity-facade-xml>""").check()
        logger.info("validate Shipment Invoice data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Purchase Invoice Accounting Transaction"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- AcctgTrans created for Approved Invoice -->
            <mantle.ledger.transaction.AcctgTrans acctgTransId="55402" acctgTransTypeEnumId="AttPurchaseInvoice"
                organizationPartyId="ORG_BIZI_RETAIL" transactionDate="${effectiveTime}" isPosted="Y"
                postedDate="${effectiveTime}" glFiscalTypeEnumId="GLFT_ACTUAL" amountUomId="USD"
                otherPartyId="MiddlemanInc" invoiceId="${invResult.invoiceId}"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55402" acctgTransEntrySeqId="01" debitCreditFlag="D"
                amount="1200" glAccountId="501000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"
                productId="DEMO_1_1" invoiceItemSeqId="01"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55402" acctgTransEntrySeqId="02" debitCreditFlag="D"
                amount="450" glAccountId="501000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"
                productId="DEMO_3_1" invoiceItemSeqId="02"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55402" acctgTransEntrySeqId="03" debitCreditFlag="D"
                amount="10,000" glAccountTypeEnumId="FIXED_ASSET" glAccountId="171000"
                reconcileStatusId="AES_NOT_RECONCILED" isSummary="N" productId="EQUIP_1" invoiceItemSeqId="03"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55402" acctgTransEntrySeqId="04" debitCreditFlag="D"
                amount="145" glAccountTypeEnumId="" glAccountId="509000" reconcileStatusId="AES_NOT_RECONCILED"
                isSummary="N" invoiceItemSeqId="04"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55402" acctgTransEntrySeqId="05" debitCreditFlag="C"
                amount="11795" glAccountTypeEnumId="ACCOUNTS_PAYABLE" glAccountId="210000"
                reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"/>
        </entity-facade-xml>""").check()
        logger.info("validate Shipment Invoice Accounting Transaction data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "send Purchase Invoice Payment"() {
        when:
        // record Payment for Invoice and apply to Invoice (will trigger GL posting for Payment and Payment Application)
        sendPmtResult = ec.service.sync().name("mantle.account.PaymentServices.send#PromisedPayment")
                .parameters([invoiceId:invResult.invoiceId, paymentId:setInfoOut.paymentId]).call()

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.account.payment.PaymentApplication paymentApplicationId="${sendPmtResult.paymentApplicationId}"
                paymentId="${setInfoOut.paymentId}" invoiceId="${invResult.invoiceId}" amountApplied="11795.00"
                appliedDate="${effectiveTime}"/>
            <!-- Payment to Delivered status, set effectiveDate -->
            <mantle.account.payment.Payment paymentId="${setInfoOut.paymentId}" statusId="PmntDelivered"
                effectiveDate="${effectiveTime}"/>
            <!-- Invoice to Payment Sent status -->
            <mantle.account.invoice.Invoice invoiceId="${invResult.invoiceId}" invoiceTypeEnumId="InvoiceSales"
                fromPartyId="MiddlemanInc" toPartyId="ORG_BIZI_RETAIL" statusId="InvoicePmtSent" invoiceDate="${effectiveTime}"
                description="Invoice for Order ${purchaseOrderId} part 01" currencyUomId="USD"/>
        </entity-facade-xml>""").check()
        logger.info("validate Shipment Invoice data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Purchase Payment Accounting Transaction"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- AcctgTrans created for Delivered Payment -->
            <mantle.ledger.transaction.AcctgTrans acctgTransId="55403" acctgTransTypeEnumId="AttOutgoingPayment"
                organizationPartyId="ORG_BIZI_RETAIL" transactionDate="${effectiveTime}" isPosted="Y"
                postedDate="${effectiveTime}" glFiscalTypeEnumId="GLFT_ACTUAL" amountUomId="USD"
                otherPartyId="MiddlemanInc" paymentId="${setInfoOut.paymentId}"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55403" acctgTransEntrySeqId="01" debitCreditFlag="D"
                amount="11795" glAccountId="216000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55403" acctgTransEntrySeqId="02" debitCreditFlag="C"
                amount="11795" glAccountId="111100" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"/>
        </entity-facade-xml>""").check()
        logger.info("validate Shipment Invoice Accounting Transaction data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Purchase Payment Application Accounting Transaction"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.ledger.transaction.AcctgTrans acctgTransId="55404" acctgTransTypeEnumId="AttOutgoingPaymentAp"
                organizationPartyId="ORG_BIZI_RETAIL" transactionDate="${effectiveTime}" isPosted="Y"
                postedDate="${effectiveTime}" glFiscalTypeEnumId="GLFT_ACTUAL" amountUomId="USD"
                otherPartyId="MiddlemanInc" paymentId="${setInfoOut.paymentId}"
                paymentApplicationId="${sendPmtResult.paymentApplicationId}"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55404" acctgTransEntrySeqId="01" debitCreditFlag="D"
                amount="11795" glAccountId="210000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"/>
            <mantle.ledger.transaction.AcctgTransEntry acctgTransId="55404" acctgTransEntrySeqId="02" debitCreditFlag="C"
                amount="11795" glAccountId="216000" reconcileStatusId="AES_NOT_RECONCILED" isSummary="N"/>
        </entity-facade-xml>""").check()
        logger.info("validate Shipment Invoice Accounting Transaction data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    // TODO: ===========================
    // TODO: alternate flow where invoice only created when items received using create#PurchaseShipmentInvoices
}
