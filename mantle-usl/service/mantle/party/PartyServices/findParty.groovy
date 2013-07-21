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
import org.moqui.entity.EntityFind
import org.moqui.entity.EntityList
import org.moqui.entity.EntityValue

// org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger("findParty")

ExecutionContext ec = context.ec

// NOTE: doing a find with a static view-entity because the Entity Facade will only select the fields specified and the
//     join in the associated member-entities
EntityFind ef = ec.entity.makeFind("FindPartyView")

ef.selectField("partyId")

if (partyTypeEnumId) { ef.condition("partyTypeEnumId", partyTypeEnumId); ef.selectField("partyTypeEnumId") }
if (roleTypeId) { ef.condition("roleTypeId", roleTypeId); ef.selectField("roleTypeId") }
if (username) { ef.condition("username", username); ef.selectField("username") }

// TODO: combinedName

if (organizationName) { ef.condition("organizationName", organizationName); ef.selectField("organizationName") }
if (firstName) { ef.condition("firstName", firstName); ef.selectField("firstName") }
if (lastName) { ef.condition("lastName", lastName); ef.selectField("lastName") }

if (address1) { ef.condition("address1", address1); ef.selectField("address1") }
if (address2) { ef.condition("address2", address2); ef.selectField("address2") }
if (city) { ef.condition("city", city); ef.selectField("city") }
if (stateProvinceGeoId) { ef.condition("stateProvinceGeoId", stateProvinceGeoId); ef.selectField("stateProvinceGeoId") }
if (postalCode) { ef.condition("postalCode", postalCode); ef.selectField("postalCode") }

if (countryCode) { ef.condition("countryCode", countryCode); ef.selectField("countryCode") }
if (areaCode) { ef.condition("areaCode", areaCode); ef.selectField("areaCode") }
if (contactNumber) { ef.condition("contactNumber", contactNumber); ef.selectField("contactNumber") }

if (emailAddress) { ef.condition("emailAddress", emailAddress); ef.selectField("emailAddress") }

if (assetSerialNumber) { ef.condition("assetSerialNumber", assetSerialNumber); ef.selectField("assetSerialNumber") }
if (contactOwnerPartyId) {
    ef.condition("contactOwnerPartyId", contactOwnerPartyId); ef.selectField("contactOwnerPartyId")
    ef.condition("contactRelationshipTypeEnumId", "PrtContact"); ef.selectField("contactRelationshipTypeEnumId")
}

if (orderByField) ef.orderBy(orderByField)

if (!pageNoLimit) { ef.offset(pageIndex as int, pageSize as int); ef.limit(pageSize as int) }

partyIdList = []
EntityList el = ef.list()
for (EntityValue ev in el) partyIdList.add(ev.partyId)

totalResults = ef.count()
