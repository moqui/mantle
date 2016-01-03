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
import org.moqui.screen.ScreenTest
import org.moqui.screen.ScreenTest.ScreenTestRender
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import spock.lang.Shared
import spock.lang.Specification
import spock.lang.Unroll

class ZzzMyAccountScreenTests extends Specification {
    protected final static Logger logger = LoggerFactory.getLogger(ZzzMyAccountScreenTests.class)

    @Shared
    ExecutionContext ec
    @Shared
    ScreenTest screenTest
    @Shared
    long effectiveTime = System.currentTimeMillis()

    def setupSpec() {
        ec = Moqui.getExecutionContext()
        // this is the user created in WorkPlanToCashBasicFlow
        ec.user.loginUser("worker", "moqui1!", null)
        screenTest = ec.screen.makeTest().baseScreenPath("apps/my")

        ec.entity.tempSetSequencedIdPrimary("mantle.party.communication.CommunicationEvent", 55850, 10)
        ec.entity.tempSetSequencedIdPrimary("mantle.work.effort.WorkEffort", 55850, 10)
    }

    def cleanupSpec() {
        long totalTime = System.currentTimeMillis() - screenTest.startTime
        logger.info("Rendered ${screenTest.renderCount} screens (${screenTest.errorCount} errors) in ${ec.l10n.format(totalTime/1000, "0.000")}s, output ${ec.l10n.format(screenTest.renderTotalChars/1000, "#,##0")}k chars")

        ec.entity.tempResetSequencedIdPrimary("mantle.party.communication.CommunicationEvent")
        ec.entity.tempResetSequencedIdPrimary("mantle.work.effort.WorkEffort")
        ec.destroy()
    }

    def setup() {
        ec.artifactExecution.disableAuthz()
    }

    def cleanup() {
        ec.artifactExecution.enableAuthz()
    }

    @Unroll
    def "render My Account screen (#screenPath, #containsTextList)"() {
        expect:
        ScreenTestRender str = screenTest.render(screenPath, null, null)
        // logger.info("Rendered ${screenPath} in ${str.getRenderTime()}ms, output:\n${str.output}")
        boolean containsAll = true
        for (String containsText in containsTextList) {
            boolean contains = containsText ? str.assertContains(containsText) : true
            if (!contains) {
                logger.info("In ${screenPath} text [${containsText}] not found:\n${str.output}")
                containsAll = false
            }

        }

        // assertions
        !str.errorMessages
        containsAll

        where:
        screenPath | containsTextList
        "User/Messages/FindMessage/createMessage?toPartyId=ORG_BLUTH_GOB&subject=Screen Test Subject&body=Screen Test Body" | []
        "User/Messages/FindMessage" | ['Screen Test Subject']
        "User/Messages/MessageThread?communicationEventId=55850" | ['Screen Test Subject']
        "User/Messages/MessageThread/SingleMessage?communicationEventId=55850" | ['Screen Test Subject', 'Screen Test Body']

        "User/Calendar" | ['New Event']
        "User/Calendar/MyCalendar/createEvent?workEffortName=Screen Test Event&purposeEnumId=WepMeeting&estimatedStartDate=${effectiveTime}&estimatedWorkDuration=2" | []
        // "User/Calendar/MyCalendar/getCalendarEvents?partyId=" | ['55850', 'Screen Test Event', 'Meeting']
        "User/Calendar/EventDetail?workEffortId=55850" | ['Screen Test Event', 'Meeting']

        "User/Task/MyTasks/createTask?purposeEnumId=WepTask&estimatedWorkTime=3&workEffortName=Screen Test Task&description=Screen Test Description" | []
        "User/Task/MyTasks" | ['55851', 'Screen Test Task', 'In Planning']
        "User/Task/TaskDetail?workEffortId=55851" |
                ['Screen Test Task', 'Screen Test Description', 'In Planning', 'Test Worker']

        "User/TimeEntries/recordTimeEntry?workEffortId=55851&rateTypeEnumId=RatpStandard&emplPositionClassId=Programmer&hours=3&pieceCount=150" | []
        "User/TimeEntries" | ['Screen Test Task', 'Standard', '3.00']
        "User/ContactInfo" | ['Email Addresses', 'Phone Numbers']
        "User/Account" | ['worker@test.com', 'Worker', 'Change Password']

        "Expense/FindExpenseInvoice" | ['Test Vendor', 'Billed Through']
        "Expense/EditExpenseInvoice?invoiceId=55900" | ['Test Worker', 'Billed Through', '849.12']
        "Expense/EditExpenseInvoiceItems?invoiceId=55900" |
                ['Expense - Travel Air', 'United SFO-LAX', 'Sales - Time Entry', '240.00']
    }
}
