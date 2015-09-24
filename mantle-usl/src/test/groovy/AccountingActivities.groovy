/*
 * This software is in the public domain under CC0 1.0 Universal.
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
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import spock.lang.Shared
import spock.lang.Specification

import java.sql.Timestamp

/* To run these make sure moqui, and mantle are in place and run:
    "gradle cleanAll load runtime/mantle/mantle-usl:test"
   Or to quick run with saved DB copy use "gradle loadSave" once then each time "gradle reloadSave runtime/mantle/mantle-usl:test"
 */

class AccountingActivities extends Specification {
    @Shared
    protected final static Logger logger = LoggerFactory.getLogger(AccountingActivities.class)
    @Shared
    ExecutionContext ec
    @Shared
    String organizationPartyId = 'ORG_ZIZI_RETAIL', currencyUomId = 'USD', timePeriodId = '55102'
    @Shared
    long effectiveTime = System.currentTimeMillis()
    @Shared
    long totalFieldsChecked = 0


    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        ec.user.loginUser("john.doe", "moqui", null)
        // set an effective date so data check works, etc
        ec.user.setEffectiveTime(new Timestamp(effectiveTime))

        ec.entity.tempSetSequencedIdPrimary("mantle.party.time.TimePeriod", 55100, 10)
    }

    def cleanupSpec() {
        ec.entity.tempResetSequencedIdPrimary("mantle.party.time.TimePeriod")

        logger.info("Accounting Activities complete, ${totalFieldsChecked} record fields checked")
    }

    def setup() {
        ec.artifactExecution.disableAuthz()
    }

    def cleanup() {
        ec.artifactExecution.enableAuthz()
    }

    def "initial Investment AcctgTrans"() {
        when:
        Map transOut = ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTrans")
                .parameters([acctgTransTypeEnumId:'AttCapitalization', organizationPartyId:organizationPartyId, amountUomId:currencyUomId]).call()
        String acctgTransId = transOut.acctgTransId
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'111100000', debitCreditFlag:'D', amount:100000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'332000000', debitCreditFlag:'C', amount:100000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.post#AcctgTrans").parameters([acctgTransId:acctgTransId]).call()

        transOut = ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTrans")
                .parameters([acctgTransTypeEnumId:'AttCapitalization', organizationPartyId:organizationPartyId, amountUomId:currencyUomId]).call()
        acctgTransId = transOut.acctgTransId
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'111100000', debitCreditFlag:'D', amount:125000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'332000000', debitCreditFlag:'C', amount:100000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'333000000', debitCreditFlag:'C', amount:25000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.post#AcctgTrans").parameters([acctgTransId:acctgTransId]).call()

        List<String> dataCheckErrors = []
        long fieldsChecked = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.ledger.account.GlAccountOrgTimePeriod glAccountId="111100000" timePeriodId="${timePeriodId}"
                    postedCredits="0" postedDebits="225000" endingBalance="225000" organizationPartyId="${organizationPartyId}"/>
            <mantle.ledger.account.GlAccountOrgTimePeriod glAccountId="332000000" timePeriodId="${timePeriodId}"
                    postedCredits="200000" postedDebits="0" endingBalance="200000" organizationPartyId="${organizationPartyId}"/>
            <mantle.ledger.account.GlAccountOrgTimePeriod glAccountId="333000000" timePeriodId="${timePeriodId}"
                    postedCredits="25000" postedDebits="0" endingBalance="25000" organizationPartyId="${organizationPartyId}"/>
        </entity-facade-xml>""").check(dataCheckErrors)
        totalFieldsChecked += fieldsChecked
        logger.info("Checked ${fieldsChecked} fields")
        if (dataCheckErrors) for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)
        if (ec.message.hasError()) logger.warn(ec.message.getErrorsString())

        then:
        dataCheckErrors.size() == 0
    }

    def "record Retained Earnings and Dividends Distributable AcctgTrans"() {
        when:
        Map transOut = ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTrans")
                .parameters([acctgTransTypeEnumId:'AttInternal', organizationPartyId:organizationPartyId, amountUomId:currencyUomId]).call()
        String acctgTransId = transOut.acctgTransId
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'850000000', debitCreditFlag:'D', amount:100000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'336000000', debitCreditFlag:'C', amount:100000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.post#AcctgTrans").parameters([acctgTransId:acctgTransId]).call()

        transOut = ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTrans")
                .parameters([acctgTransTypeEnumId:'AttInternal', organizationPartyId:organizationPartyId, amountUomId:currencyUomId]).call()
        acctgTransId = transOut.acctgTransId
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'336000000', debitCreditFlag:'D', amount:60000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'335000000', debitCreditFlag:'C', amount:60000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.post#AcctgTrans").parameters([acctgTransId:acctgTransId]).call()

        List<String> dataCheckErrors = []
        long fieldsChecked = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
        </entity-facade-xml>""").check(dataCheckErrors)
        totalFieldsChecked += fieldsChecked
        logger.info("Checked ${fieldsChecked} fields")
        if (dataCheckErrors) for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)
        if (ec.message.hasError()) logger.warn(ec.message.getErrorsString())

        then:
        dataCheckErrors.size() == 0
    }

    def "pay Dividends AcctgTrans"() {
        when:
        Map transOut = ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTrans")
                .parameters([acctgTransTypeEnumId:'AttDisbursement', organizationPartyId:organizationPartyId, amountUomId:currencyUomId]).call()
        String acctgTransId = transOut.acctgTransId
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'335000000', debitCreditFlag:'D', amount:30000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'111100000', debitCreditFlag:'C', amount:30000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.post#AcctgTrans").parameters([acctgTransId:acctgTransId]).call()

        /* pay out just one of the dividends to see amounts for both in accounts in different states
        transOut = ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTrans")
                .parameters([acctgTransTypeEnumId:'AttDisbursement', organizationPartyId:organizationPartyId, amountUomId:currencyUomId]).call()
        acctgTransId = transOut.acctgTransId
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'335000000', debitCreditFlag:'D', amount:50000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.create#AcctgTransEntry")
                .parameters([acctgTransId:acctgTransId, glAccountId:'111100000', debitCreditFlag:'C', amount:50000]).call()
        ec.service.sync().name("mantle.ledger.LedgerServices.post#AcctgTrans").parameters([acctgTransId:acctgTransId]).call()
        */

        List<String> dataCheckErrors = []
        long fieldsChecked = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
        </entity-facade-xml>""").check(dataCheckErrors)
        totalFieldsChecked += fieldsChecked
        logger.info("Checked ${fieldsChecked} fields")
        if (dataCheckErrors) for (String dataCheckError in dataCheckErrors) logger.info(dataCheckError)
        if (ec.message.hasError()) logger.warn(ec.message.getErrorsString())

        then:
        dataCheckErrors.size() == 0
    }
}
