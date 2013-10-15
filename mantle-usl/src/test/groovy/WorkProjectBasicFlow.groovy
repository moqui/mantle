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

import spock.lang.*

import org.moqui.context.ExecutionContext
import org.moqui.Moqui

class WorkProjectBasicFlow extends Specification {
    @Shared
    ExecutionContext ec

    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        ec.user.loginUser("john.doe", "moqui", null)
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

    def "create Project and Milestones"() {
        when:
        ec.service.sync().name("mantle.work.ProjectServices.create#Project")
                .parameters([workEffortId:'TEST', workEffortName:'Test Proj', clientPartyId:'ORG_BLUTH', vendorPartyId:'ORG_BIZI_SERVICES'])
                .call()
        ec.service.sync().name("mantle.work.ProjectServices.update#Project")
                .parameters([workEffortId:'TEST', workEffortName:'Test Project', statusId:'WeInProgress'])
                .call()
        ec.service.sync().name("mantle.work.ProjectServices.create#Milestone")
                .parameters([rootWorkEffortId:'TEST', workEffortId:'TEST-01', workEffortName:'Test Milestone 1',
                    estimatedStartDate:'2013-11-01', estimatedCompletionDate:'2013-11-30', statusId:'WeInProgress'])
                .call()
        ec.service.sync().name("mantle.work.ProjectServices.create#Milestone")
                .parameters([rootWorkEffortId:'TEST', workEffortId:'TEST-02', workEffortName:'Test Milestone 2',
                    estimatedStartDate:'2013-12-01', estimatedCompletionDate:'2013-12-31', statusId:'WeApproved'])
                .call()


        then:
        true
        //ec.entity.makeDataLoader().location("").check()
        // TODO: data assertions
    }
    /*
    def "create Request and update status"() {
        when:
        // TODO

        then:
        true
        // TODO: data assertions
    }

    def "create Task for Request"() {
        when:
        // TODO

        then:
        true
        // TODO: data assertions
    }

    def "record TimeEntries on Task"() {
        when:
        // TODO

        then:
        true
        // TODO: data assertions
    } */
}
