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

import org.moqui.context.ExecutionContext
import org.moqui.entity.EntityCondition
import org.moqui.entity.EntityFind
import org.moqui.entity.EntityList
import org.moqui.entity.EntityValue

// org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger("findParty")

ExecutionContext ec = context.ec

// NOTE: doing a find with a static view-entity because the Entity Facade will only select the fields specified and the
//     join in the associated member-entities
EntityFind ef = ec.entity.find("mantle.party.FindPartyView").distinct(true)

ef.selectField("partyId")

if (partyId) { ef.condition(ec.entity.conditionFactory.makeCondition("partyId", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + partyId + "%").ignoreCase()) }
if (partyTypeEnumId) { ef.condition("partyTypeEnumId", partyTypeEnumId) }
if (roleTypeId) { ef.condition("roleTypeId", roleTypeId) }
if (username) { ef.condition(ec.entity.conditionFactory.makeCondition("username", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + username + "%").ignoreCase()) }

if (combinedName) {
    // support splitting by just one space for first/last names
    String fnSplit = combinedName
    String lnSplit = combinedName
    if (combinedName.contains(" ")) {
        fnSplit = combinedName.substring(0, combinedName.indexOf(" "))
        lnSplit = combinedName.substring(combinedName.indexOf(" ") + 1)
    }
    cnCondList = [ec.entity.conditionFactory.makeCondition("organizationName", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + combinedName + "%").ignoreCase(),
            ec.entity.conditionFactory.makeCondition("firstName", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + fnSplit + "%").ignoreCase(),
            ec.entity.conditionFactory.makeCondition("lastName", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + lnSplit + "%").ignoreCase()]
    ef.condition(ec.entity.conditionFactory.makeCondition(cnCondList, EntityCondition.OR))
}

if (organizationName) { ef.condition(ec.entity.conditionFactory.makeCondition("organizationName", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + organizationName + "%").ignoreCase()) }
if (firstName) { ef.condition(ec.entity.conditionFactory.makeCondition("firstName", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + firstName + "%").ignoreCase()) }
if (lastName) { ef.condition(ec.entity.conditionFactory.makeCondition("lastName", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + lastName + "%").ignoreCase()) }

if (address1) { ef.condition(ec.entity.conditionFactory.makeCondition("address1", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + address1 + "%").ignoreCase()) }
if (address2) { ef.condition(ec.entity.conditionFactory.makeCondition("address2", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + address2 + "%").ignoreCase()) }
if (city) { ef.condition(ec.entity.conditionFactory.makeCondition("city", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + city + "%").ignoreCase()) }
if (stateProvinceGeoId) { ef.condition("stateProvinceGeoId", stateProvinceGeoId) }
if (postalCode) { ef.condition(ec.entity.conditionFactory.makeCondition("postalCode", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + postalCode + "%").ignoreCase()) }

if (countryCode) { ef.condition("countryCode", countryCode) }
if (areaCode) { ef.condition("areaCode", areaCode) }
if (contactNumber) { ef.condition(ec.entity.conditionFactory.makeCondition("contactNumber", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + contactNumber + "%")) }

if (emailAddress) { ef.condition(ec.entity.conditionFactory.makeCondition("emailAddress", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + emailAddress + "%").ignoreCase()) }

if (assetSerialNumber) { ef.condition(ec.entity.conditionFactory.makeCondition("assetSerialNumber", EntityCondition.LIKE, (leadingWildcard ? "%" : "") + assetSerialNumber + "%").ignoreCase()) }
if (contactOwnerPartyId) {
    ef.condition("contactOwnerPartyId", contactOwnerPartyId)
    ef.condition("contactRelationshipTypeEnumId", "PrtContact")
}

if (orderByField) {
    if (orderByField == "combinedName") {
        ef.orderBy("organizationName,firstName,lastName")
    } else {
        ef.orderBy(orderByField)
    }
}

if (!pageNoLimit) { ef.offset(pageIndex as int, pageSize as int); ef.limit(pageSize as int) }

// logger.warn("======= find#Party cond: ${ef.getWhereEntityCondition()}")

partyIdList = []
EntityList el = ef.list()
for (EntityValue ev in el) partyIdList.add(ev.partyId)

partyIdListCount = ef.count()
partyIdListPageIndex = ef.pageIndex
partyIdListPageSize = ef.pageSize
partyIdListPageMaxIndex = ((BigDecimal) (partyIdListCount - 1)).divide(partyIdListPageSize, 0, BigDecimal.ROUND_DOWN) as int
partyIdListPageRangeLow = partyIdListPageIndex * partyIdListPageSize + 1
partyIdListPageRangeHigh = (partyIdListPageIndex * partyIdListPageSize) + partyIdListPageSize
if (partyIdListPageRangeHigh > partyIdListCount) partyIdListPageRangeHigh = partyIdListCount
