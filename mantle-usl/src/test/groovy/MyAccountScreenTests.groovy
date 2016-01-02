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

class MyAccountScreenTests extends Specification {
    protected final static Logger logger = LoggerFactory.getLogger(MyAccountScreenTests.class)

    @Shared
    ExecutionContext ec
    @Shared
    ScreenTest screenTest

    def setupSpec() {
        ec = Moqui.getExecutionContext()
        ec.user.loginUser("john.doe", "moqui", null)
        screenTest = ec.screen.makeTest().baseScreenPath("apps/my")
    }

    def cleanupSpec() {
        long totalTime = System.currentTimeMillis() - screenTest.startTime
        logger.info("Rendered ${screenTest.renderCount} screens (${screenTest.errorCount} errors) in ${ec.l10n.format(totalTime/1000, "0.000")}s, output ${ec.l10n.format(screenTest.renderTotalChars/1000, "#,##0")}k chars")
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
        "User/Messages/FindMessage" | ['Received', 'Gob Bluth', 'Comment']
        "User/Messages/MessageThread?communicationEventId=HM-004-01-A1A" | ['Remaining hours question']
        "User/Messages/MessageThread/SingleMessage?communicationEventId=HM-004-01-A1A" | ['Gob Bluth', 'John Doe', "It's about time"]
        "User/Calendar" | ['New Event']
        "User/Task" | ['Dashboard My Tasks', 'In Progress']
        "User/TimeEntries" | ['Another Company Making Everything', 'Programmer Lead', 'Standard']
        "User/ContactInfo" | ['Email Addresses', 'Phone Numbers']
        "User/Account" | ['john.doe@test.com', 'John', 'Change Password']
    }
}
