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
    String returnId = null, originalOrderId = "55500", returnShipmentId, replaceOrderId, replaceOrderPartSeqId
    @Shared
    Map replaceShipResult
    @Shared
    long effectiveTime = System.currentTimeMillis()

    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        // set an effective date so data check works, etc
        ec.user.setEffectiveTime(new Timestamp(effectiveTime))

        ec.entity.tempSetSequencedIdPrimary("mantle.account.method.PaymentGatewayResponse", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.shipment.ShipmentItemSource", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.asset.Asset", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.asset.AssetDetail", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.issuance.AssetReservation", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.issuance.AssetIssuance", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.product.receipt.AssetReceipt", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.invoice.Invoice", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.account.payment.PaymentApplication", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.order.OrderHeader", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.order.return.ReturnHeader", 55700, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.order.return.ReturnItemBilling", 55700, 10)
    }

    def cleanupSpec() {
        ec.entity.tempResetSequencedIdPrimary("mantle.account.method.PaymentGatewayResponse")
        ec.entity.tempResetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans")
        ec.entity.tempResetSequencedIdPrimary("mantle.shipment.ShipmentItemSource")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.asset.Asset")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.asset.AssetDetail")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.issuance.AssetReservation")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.issuance.AssetIssuance")
        ec.entity.tempResetSequencedIdPrimary("mantle.product.receipt.AssetReceipt")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.invoice.Invoice")
        ec.entity.tempResetSequencedIdPrimary("mantle.account.payment.PaymentApplication")
        ec.entity.tempResetSequencedIdPrimary("mantle.order.OrderHeader")
        ec.entity.tempResetSequencedIdPrimary("mantle.order.return.ReturnHeader")
        ec.entity.tempResetSequencedIdPrimary("mantle.order.return.ReturnItemBilling")
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

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
        </entity-facade-xml>""").check()
        logger.info("create Sales Order data check results: " + dataCheckErrors)

        then:

        dataCheckErrors.size() == 0
    }

    def "approve Return"() {
        when:
        ec.user.loginUser("john.doe", "moqui", null)

        // triggers SECA rule to create an Sales Return (incoming) Shipment
        ec.service.sync().name("mantle.order.ReturnServices.approve#Return").parameters([returnId:returnId]).call()

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
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

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
        </entity-facade-xml>""").check()
        logger.info("receive Return Shipment data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Refund Payment and Customer Credit TX"() {
        when:

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
        </entity-facade-xml>""").check()
        logger.info("validate Refund Payment and Customer Credit TX data check results: ")
        for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Replacement Order and Asset Reservation"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
        </entity-facade-xml>""").check()
        logger.info("validate Replacement Order and Asset Reservation data check results: ")
        for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)

        then:
        dataCheckErrors.size() == 0
    }

    /*
    def "ship Replacement Order"() {
        when:

        shipResult = ec.service.sync().name("mantle.shipment.ShipmentServices.ship#OrderPart")
                .parameters([orderId:cartOrderId, orderPartSeqId:orderPartSeqId]).call()

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
        </entity-facade-xml>""").check()
        logger.info("ship Replacement Order data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Replacement Order Complete"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <!-- OrderHeader status to Completed -->
            <mantle.order.OrderHeader orderId="${replaceOrderId}" statusId="OrderCompleted"/>
        </entity-facade-xml>""").check()
        logger.info("validate Replacement Order Complete data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "validate Asset Issuance and Accounting Transactions"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
        </entity-facade-xml>""").check()
        logger.info("validate Asset Issuance and Accounting Transactions data check results: ")
        for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)

        then:
        dataCheckErrors.size() == 0
    }


    def "validate Payment and Accounting Transaction"() {
        when:
        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
        </entity-facade-xml>""").check()
        logger.info("validate Payment and Accounting Transaction data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }
    */
}
