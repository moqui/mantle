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

import org.slf4j.LoggerFactory
import org.slf4j.Logger

import java.sql.Timestamp

class WorkProjectBasicFlow extends Specification {
    @Shared
    protected final static Logger logger = LoggerFactory.getLogger(WorkProjectBasicFlow.class)
    @Shared
    ExecutionContext ec

    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        ec.user.loginUser("john.doe", "moqui", null)
        // set an effective date so data check works, etc
        ec.user.setEffectiveTime(ec.l10n.parseTimestamp("2013-11-02 12:00:00.0", null))
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

    def "create TEST Project"() {
        when:
        ec.service.sync().name("mantle.work.ProjectServices.create#Project")
                .parameters([workEffortId:'TEST', workEffortName:'Test Proj', clientPartyId:'ORG_BLUTH', vendorPartyId:'ORG_BIZI_SERVICES'])
                .call()
        ec.service.sync().name("mantle.work.ProjectServices.update#Project")
                .parameters([workEffortId:'TEST', workEffortName:'Test Project', statusId:'WeInProgress'])
                .call()

        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.work.effort.WorkEffort workEffortId="TEST" workEffortTypeEnumId="WetProject" statusId="WeInProgress" workEffortName="Test Project"/>
            <mantle.work.effort.WorkEffortParty workEffortId="TEST" partyId="EX_JOHN_DOE" roleTypeId="Manager" fromDate="2013-11-02 12:00:00.0" statusId="PRTYASGN_ASSIGNED"/>
            <mantle.work.effort.WorkEffortParty workEffortId="TEST" partyId="ORG_BLUTH" roleTypeId="CustomerBillTo" fromDate="2013-11-02 12:00:00.0"/>
            <mantle.work.effort.WorkEffortParty workEffortId="TEST" partyId="ORG_BIZI_SERVICES" roleTypeId="VendorBillFrom" fromDate="2013-11-02 12:00:00.0"/>
            <!-- how to handle seqId?
            <moqui.entity.EntityAuditLog auditHistorySeqId="100151" changedEntityName="mantle.work.effort.WorkEffortParty" changedFieldName="statusId" pkPrimaryValue="TEST" pkSecondaryValue="EX_JOHN_DOE" pkRestCombinedValue="roleTypeId=Manager,fromDate=2013-11-02 12:00:00.0" newValueText="PRTYASGN_ASSIGNED" changedByUserId="EX_JOHN_DOE"/>
            <moqui.entity.EntityAuditLog auditHistorySeqId="100150" changedEntityName="mantle.work.effort.WorkEffort" changedFieldName="statusId" pkPrimaryValue="TEST" newValueText="WeInPlanning" changedByUserId="EX_JOHN_DOE"/>
            <moqui.entity.EntityAuditLog auditHistorySeqId="100152" changedEntityName="mantle.work.effort.WorkEffort" changedFieldName="statusId" pkPrimaryValue="TEST" oldValueText="WeInPlanning" newValueText="WeInProgress" changedByUserId="EX_JOHN_DOE"/>
            -->
            </entity-facade-xml>""").check()
        logger.info("TEST Project data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "create TEST Milestones"() {
        when:
        ec.service.sync().name("mantle.work.ProjectServices.create#Milestone")
                .parameters([rootWorkEffortId:'TEST', workEffortId:'TEST-MS-01', workEffortName:'Test Milestone 1',
                estimatedStartDate:'2013-11-01', estimatedCompletionDate:'2013-11-30', statusId:'WeInProgress'])
                .call()
        ec.service.sync().name("mantle.work.ProjectServices.create#Milestone")
                .parameters([rootWorkEffortId:'TEST', workEffortId:'TEST-MS-02', workEffortName:'Test Milestone 2',
                estimatedStartDate:'2013-12-01', estimatedCompletionDate:'2013-12-31', statusId:'WeApproved'])
                .call()

        List<String> dataCheckErrors = ec.entity.makeDataLoader().xmlText("""<entity-facade-xml>
            <mantle.work.effort.WorkEffort workEffortId="TEST-MS-01" rootWorkEffortId="TEST" workEffortTypeEnumId="WetMilestone" statusId="WeInProgress" workEffortName="Test Milestone 1" estimatedStartDate="2013-11-01 00:00:00.0" estimatedCompletionDate="2013-11-30 00:00:00.0"/>
            <mantle.work.effort.WorkEffort workEffortId="TEST-MS-02" rootWorkEffortId="TEST" workEffortTypeEnumId="WetMilestone" statusId="WeApproved" workEffortName="Test Milestone 2" estimatedStartDate="2013-12-01 00:00:00.0" estimatedCompletionDate="2013-12-31 00:00:00.0"/>
            <!-- how to handle seqId?
            <moqui.entity.EntityAuditLog auditHistorySeqId="100153" changedEntityName="mantle.work.effort.WorkEffort" changedFieldName="statusId" pkPrimaryValue="TEST-MS-01" newValueText="WeInProgress" changedByUserId="EX_JOHN_DOE"/>
            <moqui.entity.EntityAuditLog auditHistorySeqId="100154" changedEntityName="mantle.work.effort.WorkEffort" changedFieldName="statusId" pkPrimaryValue="TEST-MS-02" newValueText="WeApproved" changedByUserId="EX_JOHN_DOE"/>
            -->
            </entity-facade-xml>""").check()
        logger.info("TEST Milestones data check results: " + dataCheckErrors)

        then:
        dataCheckErrors.size() == 0
    }

    def "create TEST Project Tasks"() {
        when:
        ec.service.sync().name("mantle.work.TaskServices.create#Task")
                .parameters([rootWorkEffortId:'TEST', parentWorkEffortId:null, workEffortId:'TEST-001', milestoneWorkEffortId:'TEST-MS-01',
                workEffortName:'Test Task 1', estimatedCompletionDate:'2013-11-15', statusId:'WeApproved',
                assignToPartyId:'ORG_BIZI_JD', priority:3, purposeEnumId:'WepTask', estimatedWorkTime:10,
                description:'Will be really great when it\'s done'])
                .call()
        ec.service.sync().name("mantle.work.TaskServices.create#Task")
                .parameters([rootWorkEffortId:'TEST', parentWorkEffortId:'TEST-001', workEffortId:'TEST-001A', milestoneWorkEffortId:'TEST-MS-01',
                workEffortName:'Test Task 1A', estimatedCompletionDate:'2013-11-15', statusId:'WeInPlanning',
                assignToPartyId:'ORG_BIZI_JD', priority:4, purposeEnumId:'WepNewFeature', estimatedWorkTime:2,
                description:'One piece of the puzzle'])
                .call()
        ec.service.sync().name("mantle.work.TaskServices.create#Task")
                .parameters([rootWorkEffortId:'TEST', parentWorkEffortId:'TEST-001', workEffortId:'TEST-001B', milestoneWorkEffortId:'TEST-MS-01',
                workEffortName:'Test Task 1B', estimatedCompletionDate:'2013-11-15', statusId:'WeApproved',
                assignToPartyId:'ORG_BIZI_JD', priority:4, purposeEnumId:'WepFix', estimatedWorkTime:2,
                description:'Broken piece of the puzzle'])
                .call()

        then:
        true
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
