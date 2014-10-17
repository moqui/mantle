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
class OrderToCashTime extends Specification {
    @Shared
    protected final static Logger logger = LoggerFactory.getLogger(OrderToCashTime.class)
    @Shared
    ExecutionContext ec

    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
    }

    def cleanupSpec() {
        ec.destroy()
    }

    def setup() {
        ec.artifactExecution.disableAuthz()
    }

    def cleanup() {
        ec.artifactExecution.enableAuthz()
    }

    def "Sales Order Time Check"() {
        when:
        int numOrders = 5

        long startTime = System.currentTimeMillis()
        for (int i = 0; i < numOrders; i++) {
            ec.user.loginUser("joe@public.com", "moqui", null)

            String productStoreId = "POPC_DEFAULT"
            EntityValue productStore = ec.entity.find("mantle.product.store.ProductStore").condition("productStoreId", productStoreId).useCache(true).one()
            String currencyUomId = productStore.defaultCurrencyUomId
            // String priceUomId = productStore.defaultCurrencyUomId
            // String defaultLocale = productStore.defaultLocale
            // String organizationPartyId = productStore.organizationPartyId
            // String vendorPartyId = productStore.organizationPartyId
            String customerPartyId = ec.user.userAccount.partyId

            Map addOut1 = ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                    .parameters([productId:'DEMO_1_1', quantity:1, customerPartyId:customerPartyId,
                    currencyUomId:currencyUomId, productStoreId:productStoreId]).call()

            String cartOrderId = addOut1.orderId
            String orderPartSeqId = addOut1.orderPartSeqId

            ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                    .parameters([orderId:cartOrderId, productId:'DEMO_3_1', quantity:1, customerPartyId:customerPartyId,
                    currencyUomId:currencyUomId, productStoreId:productStoreId]).call()
            ec.service.sync().name("mantle.order.OrderServices.add#OrderProductQuantity")
                    .parameters([orderId:cartOrderId, productId:'DEMO_2_1', quantity:1, customerPartyId:customerPartyId,
                    currencyUomId:currencyUomId, productStoreId:productStoreId]).call()

            ec.service.sync().name("mantle.order.OrderServices.set#OrderBillingShippingInfo")
                    .parameters([orderId:cartOrderId, paymentMethodId:'CustJqpCc', shippingPostalContactMechId:'CustJqpAddr',
                    shippingTelecomContactMechId:'CustJqpTeln', carrierPartyId:'_NA_', shipmentMethodEnumId:'ShMthGround']).call()
            ec.service.sync().name("mantle.order.OrderServices.place#Order").parameters([orderId:cartOrderId]).call()

            ec.user.logoutUser()

            ec.user.loginUser("john.doe", "moqui", null)
            ec.service.sync().name("mantle.shipment.ShipmentServices.ship#OrderPart")
                    .parameters([orderId:cartOrderId, orderPartSeqId:orderPartSeqId]).call()
            ec.user.logoutUser()

            logger.info("[${i+1}/${numOrders} - ${System.currentTimeMillis() - startTime}] Created and shipped order ${cartOrderId}")
        }
        long endTime = System.currentTimeMillis()
        double seconds = (endTime - startTime)/1000
        logger.info("Created and shipped ${numOrders} in ${seconds} seconds, ${numOrders/seconds} orders per second")

        then:
        true
    }
}
