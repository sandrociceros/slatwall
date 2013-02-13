/*

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/
component entityname="SlatwallPhysicalCount" table="SlatwallPhysicalCount" persistent="true" accessors="true" extends="HibachiEntity" {
	
	// Persistent Properties
	property name="physicalCountID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";

	// Calculated Properties

	// Related Object Properties (many-to-one)
	property name="location" cfc="Location" fieldtype="many-to-one" fkcolumn="locationID";
	property name="physical" cfc="Physical" fieldtype="many-to-one" fkcolumn="physicalID";
	
	// Related Object Properties (one-to-many)
	property name="physicalCountItems" singularname="physicalCountItem" cfc="PhysicalCountItem" type="array" fieldtype="one-to-many" fkcolumn="physicalCountID" cascade="all-delete-orphan" inverse="true";
	
	// Related Object Properties (many-to-many - owner)

	// Related Object Properties (many-to-many - inverse)
	
	// Remote Properties
	property name="remoteID" ormtype="string";
	
	// Audit Properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Non-Persistent Properties
	property name="physicalStatusTypeSystemCode" persistent="false";


	
	// ============ START: Non-Persistent Property Methods =================
	
	public string function getPhysicalStatusTypeSystemCode() {
		return getPhysical().getPhysicalStatusTypeSystemCode();
	}
	
	// ============  END:  Non-Persistent Property Methods =================
		
	// ============= START: Bidirectional Helper Methods ===================
	
	
	// Physical (many-to-one)    
	public void function setPhysical(required any physical) {    
		variables.physical = arguments.physical;
		if(isNew() or !arguments.physical.hasPhysicalCount( this )) {    
			arrayAppend(arguments.physical.getPhysicalCounts(), this);    
		}    
	}    
	public void function removePhysical(any physical) {    
		if(!structKeyExists(arguments, "physical")) {    
			arguments.physical = variables.physical;    
		}    
		var index = arrayFind(arguments.physical.getPhysicalCounts(), this);    
		if(index > 0) {    
			arrayDeleteAt(arguments.physical.getPhysicalCounts(), index);    
		}    
		structDelete(variables, "physical");    
	}
	
	// Physical Count Items (one-to-many)
	public void function addPhysicalCountItem(required any physicalCountItem) {
		arguments.physicalCountItem.setPhysicalCount( this );
	}
	public void function removePhysicalCountItem(required any physicalCountItem) {
		arguments.physicalCountItem.removePhysicalCount( this );
	}
	
	// =============  END:  Bidirectional Helper Methods ===================

	// =============== START: Custom Validation Methods ====================
	
	// ===============  END: Custom Validation Methods =====================
	
	// =============== START: Custom Formatting Methods ====================
	
	// ===============  END: Custom Formatting Methods =====================
	
	// ============== START: Overridden Implicet Getters ===================
	
	// ==============  END: Overridden Implicet Getters ====================

	// ================== START: Overridden Methods ========================
	
	public string function getSimpleRepresentationPropertyName() {
		return "location";
	}
	
	// ==================  END:  Overridden Methods ========================
	
	// =================== START: ORM Event Hooks  =========================
	
	// ===================  END:  ORM Event Hooks  =========================
	
	// ================== START: Deprecated Methods ========================
	
	// ==================  END:  Deprecated Methods ========================
}