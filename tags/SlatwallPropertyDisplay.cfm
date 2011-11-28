<!---

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

--->

<!--- These are required Attributes --->
<cfparam name="attributes.object" type="any" />										<!--- hint: This is a required attribute that defines the object that contains the property to display --->
<cfparam name="attributes.property" type="string" /> 								<!--- hint: This is a required attribute as the property that you want to display" --->

<!--- These are optional Attributes --->
<cfparam name="attributes.edit" type="boolean" default="false" />					<!--- hint: When in edit mode this will create a Form Field, otherwise it will just display the value" --->

<cfparam name="attributes.title" type="string" default="" />						<!--- hint: This can be used to override the displayName of a property" --->

<cfparam name="attributes.value" type="string" default="" />						<!--- hint: This can be used to override the value of a property --->
<cfparam name="attributes.valueOptions" type="array" default="#arrayNew(1)#" />		<!--- hint: This can be used to set a default value for the property IF it hasn't been defined  NOTE: right now this only works for select boxes--->
<cfparam name="attributes.valueDefault" type="string" default="" />					<!--- hint: This can be used to set a default value for the property IF it hasn't been defined  NOTE: right now this only works for select boxes--->
<cfparam name="attributes.valueLink" type="string" default="" />					<!--- hint: if specified, will wrap property value with an achor tag using the attribute as the href value --->
<cfparam name="attributes.valueDisplayFormat" type="string" default="" />			<!--- hint: This can be used to defined the format of this property wehn it is displayed --->

<cfparam name="attributes.fieldName" type="string" default="" />					<!--- hint: This can be used to override the default field name" --->
<cfparam name="attributes.fieldType" type="string" default="" />					<!--- hint: When in edit mode you can override the default type of form object to use" --->

<cfparam name="attributes.titleClass" default="" />									<!--- hint: Adds class to whatever markup wraps the title element --->
<cfparam name="attributes.valueClass" default="" />									<!--- hint: Adds class to whatever markup wraps the value element --->
<cfparam name="attributes.fieldClass" default="" />									<!--- hint: Adds class to the actual field element --->
<cfparam name="attributes.valueLinkClass" default="" />								<!--- hint: Adds class to whatever markup wraps the value link element --->

<cfparam name="attributes.toggle" type="string" default="no" />						<!--- hint: This attribute indicates whether the field can be toggled to show/hide the value. Possible values are "no" (no toggling), "Show" (shows field by default but can be toggled), or "Hide" (hide field by default but can be toggled) --->
<cfparam name="attributes.displayType" default="dl" />								<!--- hint: This attribute is used to specify if the information comes back as a definition list (dl) item or table row (table) or with no formatting or label (plain) --->

<!---
	attributes.fieldType have the following options:
	
	checkbox			|	As a single checkbox this doesn't require any options, but it will create a hidden field for you so that the key gets submitted even when not checked.  The value of the checkbox will be 1
	checkboxgroup		|	Requires the valueOptions to be an array of structs with the format of {value="", name=""}
	date				|	This is still just a textbox, but it adds the jQuery date picker
	dateTime			|	This is still just a textbox, but it adds the jQuery date & time picker
	file				|	No value can be passed in
	multiselect			|	Requires the valueOptions to be an array of structs with the format of {value="", name=""}
	password			|	No Value can be passed in
	radiogroup			|	Requires the valueOptions to be an array of structs with the format of {value="", name=""}
	select      		|	Requires the valueOptions to be an array of structs with the format of {value="", name=""}
	text				|	Simple Text Field
	textarea			|	Simple Textarea
	time				|	This is still just a textbox, but it adds the jQuery time picker
	wysiwyg				|	Value needs to be a string
	yesno				|	This is used by booleans and flags to create a radio group of Yes and No
	
--->

<!---
	attributes.displayType have the following options:
	dl
	table
	span
	plain
--->

<cfif thisTag.executionMode is "start">
	
	<!--- Set Up The Value --->
	<cfif attributes.value eq "">
		
		<cfset attributes.value = attributes.object.getValueByPropertyIdentifier( attributes.property ) />
		
		<cfif isNull(attributes.value) || (isSimpleValue(attributes.value) && attributes.value eq "")>
			<cfset attributes.value = attributes.valueDefault />
		</cfif>
		
		<!--- If the value was an object, typically a MANY-TO-ONE, then we get either the identifierValue or for display a simpleRepresentation --->
		<cfif isObject(attributes.value)>
			<cfif attributes.edit>
				<cfif attributes.object.isPersistent()>
					<cfset attributes.value = attributes.value.getIdentifierValue() />
				<cfelse>
					<cfset attributes.value = attributes.valueDefault />
				</cfif>
			<cfelse>
				<cfset attributes.value = attributes.value.getSimpleRepresentation() />
			</cfif>
		</cfif>
		
		<!--- Final check to make sure that the value is simple --->
		<cfif not isSimpleValue(attributes.value)>
			<cfif isSimpleValue(attributes.valueDefault)>
				<cfset attributes.value = attributes.valueDefault />
			<cfelse>
				<cfset attributes.value = "" />
			</cfif>
		</cfif>
		
	</cfif>
	
	<!--- Set up the property title --->
	<cfif attributes.title eq "">
		<cfset attributes.title = attributes.object.getPropertyTitle( attributes.property ) />
	</cfif>
	
	<!--- Set up the displayFormat --->
	<cfif attributes.valueDisplayFormat eq "">
		<cfset attributes.valueDisplayFormat = attributes.object.getPropertyValueDisplayFormat( attributes.property ) />
	</cfif>
	
	<!--- If this is in edit mode then get the pertinent field info --->
	<cfif attributes.edit>
		<cfif attributes.fieldName eq "">
			<cfset attributes.fieldName = attributes.object.getPropertyFieldName( attributes.property ) />
		</cfif>
		<cfif attributes.fieldType eq "">
			<cfset attributes.fieldType = attributes.object.getPropertyFieldType( attributes.property ) />
		</cfif>
		<cfif listFindNoCase("checkboxgroup,radiogroup,select", attributes.fieldType) and not arrayLen(attributes.valueOptions)>
			<cfset attributes.valueOptions = attributes.object.invokeMethod( "get#attributes.property#Options" ) />
		</cfif>
	</cfif>
	
	<!--- Set up all of the classes --->
	<cfset attributes.titleClass = trim("title #lcase(attributes.property)#title #attributes.titleClass#") />
	<cfset attributes.valueClass = trim("value #lcase(attributes.property)#value #attributes.valueClass#") />
	<cfset attributes.valueLinkClass = trim("valuelink #lcase(attributes.property)#valuelink #attributes.valueLinkClass#") />
	<cfset attributes.fieldClass = trim("field #lcase(attributes.property)#field #attributes.fieldClass#") />
	
	<cfset local = structNew() />
	
	<cfswitch expression="#attributes.displaytype#">
		<!--- DL Case --->
		<cfcase value="dl">
			<cfif attributes.edit>
				<cfoutput>
					<dt class="#attributes.titleClass#"><label for="#attributes.fieldName#">#attributes.title#</label></dt>
					<dd class="#attributes.valueClass#">
						<cfif attributes.object.hasError(attributes.property)>
							<cfloop array="#attributes.object.getErrorsByName( attributes.property )#" index="error">
								<div class="error">#error#</div>
							</cfloop>
						</cfif>
						<cf_SlatwallFormField fieldType="#attributes.fieldType#" fieldName="#attributes.fieldName#" fieldClass="#attributes.fieldClass#" value="#attributes.value#" valueOptions="#attributes.valueOptions#" />
					</dd>
				</cfoutput>
			<cfelse>
				<cfoutput>
					<dt class="#attributes.titleClass#">#attributes.title#</dt>
					<dd class="#attributes.valueClass#">#attributes.value#</dd>
				</cfoutput>
			</cfif>
		</cfcase>
		<!--- TABLE Display --->
		<cfcase value="table">
			<cfif attributes.edit>
				<cfoutput>
					<tr>
						<td class="#attributes.titleClass#"><label for="#attributes.fieldName#">#attributes.title#</label></td>
						<td class="#attributes.valueClass#">
							<cfif attributes.object.hasError(attributes.property)>
								<cfloop array="#attributes.object.getErrorsByName( attributes.property )#" index="error">
									<div class="error">#error#</div>
								</cfloop>
							</cfif>
							<cf_SlatwallFormField fieldType="#attributes.fieldType#" fieldName="#attributes.fieldName#" fieldClass="#attributes.fieldClass#" value="#attributes.value#" valueOptions="#attributes.valueOptions#" />
						</td>
					</tr>
				</cfoutput>
			<cfelse>
				<cfoutput>
					<tr>
						<td class="#attributes.titleClass#">#attributes.title#</td>
						<td class="#attributes.valueClass#">#attributes.value#</td>
					</tr>
				</cfoutput>
			</cfif>
		</cfcase>
		<!--- INLINE Display --->
		<cfcase value="span">
			<cfif attributes.edit>
				<cfoutput>
					<span class="#attributes.titleClass#"><label for="#attributes.fieldName#">#attributes.title#</label></span>
					<span class="#attributes.valueClass#">
						<cfif attributes.object.hasError(attributes.property)>
							<cfloop array="#attributes.object.getErrorsByName( attributes.property )#" index="error">
								<div class="error">#error#</div>
							</cfloop>
						</cfif>
						<cf_SlatwallFormField fieldType="#attributes.fieldType#" fieldName="#attributes.fieldName#" fieldClass="#attributes.fieldClass#" value="#attributes.value#" valueOptions="#attributes.valueOptions#" />
					</span>
				</cfoutput>
			<cfelse>
				<cfoutput>
					<span class="#attributes.titleClass#">#attributes.title#: </span>
					<span class="#attributes.valueClass#">#attributes.value#</span>
				</cfoutput>
			</cfif>
		</cfcase>
		<!--- Plain Display (value only) --->
		<cfcase value="plain">
			<cfif attributes.edit>
				<cfoutput>
					<cf_SlatwallFormField fieldType="#attributes.fieldType#" fieldName="#attributes.fieldName#" fieldClass="#attributes.fieldClass#" value="#attributes.value#" valueOptions="#attributes.valueOptions#" />
				</cfoutput>
			<cfelse>
				<cfoutput>
					#attributes.value#	
				</cfoutput>
			</cfif>
		</cfcase>
	</cfswitch>	
</cfif>