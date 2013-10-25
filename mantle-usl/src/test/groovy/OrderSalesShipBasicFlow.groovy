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

    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        // set an effective date so data check works, etc; Long value (when set from Locale of john.doe, US/Central): 1383411600000
        ec.user.setEffectiveTime(ec.l10n.parseTimestamp("2013-11-02 12:00:00.0", null))

        ec.entity.tempSetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans", 55500, 10)
    }

    def cleanupSpec() {
        ec.entity.tempResetSequencedIdPrimary("mantle.ledger.transaction.AcctgTrans")
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

        ec.service.sync().name("mantle.order.OrderServices.set#OrderBillingShippingInfo")
                .parameters([orderId:cartOrderId, paymentMethodId:'CustJqpCc', shippingPostalContactMechId:'CustJqpAddr',
                    shippingTelecomContactMechId:'CustJqpTeln', shipmentMethodEnumId:'ShMthNoShipping']).call()
        ec.service.sync().name("mantle.order.OrderServices.place#Order").parameters([orderId:cartOrderId]).call()

        ec.user.logoutUser()

        // NOTE: this has sequenced IDs so is sensitive to run order!
        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
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
        </entity-facade-xml>""").check()
        logger.info("ship Sales Order data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }
}
