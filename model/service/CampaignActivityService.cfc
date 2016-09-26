/*

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) ten24, LLC

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

    Linking this program statically or dynamically with other modules is
    making a combined work based on this program.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.

    As a special exception, the copyright holders of this program give you
    permission to combine this program with independent modules and your
    custom code, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting program under terms
    of your choice, provided that you follow these specific guidelines:

	- You also meet the terms and conditions of the license of each
	  independent module
	- You must not alter the default display of the Slatwall name or logo from
	  any part of the application
	- Your custom code must not alter or create any files inside Slatwall,
	  except in the following directories:
		/integrationServices/

	You may copy and distribute the modified version of this program that meets
	the above guidelines as a combined work under the terms of GPL for this program,
	provided that you include the source code of that other code when and as the
	GNU GPL requires distribution of source code.

    If you modify this program, you may extend this exception to your version
    of the program, but you are not obligated to do so.

Notes:

*/
component extends="HibachiService" persistent="false" accessors="true" output="false" {

	property name="campaignActivityLinkDAO" type="any";
	property name="campaignActivityAccountDAO" type="any";

	// ===================== START: Logical Methods ===========================

	public string function mergeCampaignActivitiesCollectionConfig(required string campaignActivityIds) {
		if(!len(campaignActivityIds)) return '';

		var campaignActivityIdArray = listToArray (campaignActivityIds);

		for( currentId in campaignActivityIdArray ){
			var currentCampaign = this.getCampaign(currentId);

			var currentCollectionConfig = currentCampaign.getCollectionConfig();

			if(isNull(currentCollectionConfig) || len(currentCollectionConfig) == 0 ) {
				continue;
			}

			var currentCollectionConfigStruct = DeserializeJSON(currentCollectionConfig);

			if(!hasFilters(currentCollectionConfigStruct)){
				continue;
			}

			if(isNull(mergedCollectionConfig)){
				var mergedCollectionConfig = currentCollectionConfigStruct;
				continue;
			}

			var totalFilterGroups = arrayLen(currentCollectionConfigStruct.filterGroups);
			for(var i =1; i <= totalFilterGroups; i++){
				if(!ArrayIsDefined(mergedCollectionConfig.filterGroups, i)){
					mergedCollectionConfig.filterGroups[i] = { "filterGroup" = []};
				}
				ArrayAppend(mergedCollectionConfig.filterGroups[i].filterGroup, currentCollectionConfigStruct.filterGroups[i].filterGroup, true);
			}
		}

		return SerializeJSON(mergedCollectionConfig);

	}

	private boolean function hasFilters(required struct collectionConfig){
		return (
			structKeyExists(collectionConfig, 'filterGroups')
			&& arraylen(collectionConfig.filterGroups) > 0
			&& structKeyExists(collectionConfig.filterGroups[1],'filterGroup')
			&& arraylen(collectionConfig.filterGroups[1].filterGroup) > 0
		);
	}


	private boolean function isReadyToSend(required any campaignActivity){
		var requiredProperties =  ListToArray('campaignActivityDescription,collectionConfig,emailSubject,emailFromName,'&
		'emailFromEmail,emailReplyTo,emailStyle,emailBodyHTML,emailBodyText');

		for (i = 1; i <= ArrayLen(requiredProperties); i++) {
			if(isNull(arguments.campaignActivity.invokeMethod('get#requiredProperties[i]#'))){
				return false;
			}
		}
		return true;
	}

	private boolean function isEmailReady(required any campaignActivity){
		var requiredProperties =  ListToArray('campaignActivityDescription,emailSubject,emailFromName,'&
		'emailFromEmail,emailReplyTo,emailStyle,emailBodyHTML,emailBodyText');

		for (i = 1; i <= ArrayLen(requiredProperties); i++) {
			if(isNull(arguments.campaignActivity.invokeMethod('get#requiredProperties[i]#'))){
				return false;
			}
		}
		return true;
	}

	private boolean function isEmailChanged(required any campaignActivity, required struct data){
		var properties =  ListToArray('campaignActivityName,emailSubject,emailFromName,'&
		'emailFromEmail,emailReplyTo,emailStyle,emailBodyHTML,emailBodyText');

		for (i = 1; i <= ArrayLen(properties); i++) {
			if(structKeyExists(arguments.data, properties[i]) && arguments.campaignActivity.invokeMethod('get#properties[i]#') != arguments.data[properties[i]]) {
				return true;
			}
		}
		return false;
	}


	private any function getEmailService(){
		return getService("send24Service");
	}

	private void function scrapeLinks(required string campaignActivityID,required string emailBody){
		var urlList = '';
		var pattern = CreateObject("java", "java.util.regex.Pattern").Compile(JavaCast( "string", "<a\s+(?:[^>]*?\s+)?href=[\x22\x27]([^\x22\x27]+)\x22"));
		var matcher = pattern.Matcher(JavaCast( "string", arguments.emailBody));
		while (matcher.Find()) {
			if(!ListFind(urlList, matcher.Group(JavaCast('int',1)))){
				urlList = ListAppend(urlList, matcher.Group(JavaCast('int',1)));
			}
		}
		if(listLen(urlList)){
			getCampaignActivityLinkDAO().insertLink(urls=urlList,campaignActivityID=arguments.campaignActivityID);
		}
	}


	public any function saveCampaignActivity(required any campaignActivity, required struct data={}, required string context){
		getService("HibachiTagService").cfsetting(requesttimeout="6000");
		var emailChanged = isEmailChanged(campaignActivity, data);

		if(structKeyExists(arguments.data,'listIDs')){
			arguments.data['collectionConfig'] = mergeCampaignActivitiesCollectionConfig(arguments.data.listIDs);
		}

		//HACK.
		if(structKeyExists(arguments.data, 'campaign.campaignID')){
			arguments.data['campaign'] = {
				'campaignID' =  arguments.data['campaign.campaignID']
			};
		}

		arguments.campaignActivity = super.save(arguments.campaignActivity,arguments.data, arguments.context);

		if(arguments.campaignActivity.hasErrors()){
			return arguments.campaignActivity;
		}

		if(isReadyToSend(arguments.campaignActivity)){
			if((context == "schedule" || arguments.campaignActivity.getCampaignActivityStatus().getTypeID() == '402828c656eafa1d01574400d4920249')&& structKeyExists(arguments.data, "emailSendDateTime")){
				//Scheduled
				arguments.campaignActivity.setCampaignActivityStatus(this.getType('402828c656eafa1d01574400d4920249'));
			}else{
				//Ready to Send
				arguments.campaignActivity.setCampaignActivityStatus(this.getType('402828c656eafa1d0157108d4739012a'));
			}
		}else{
			//Pending
			arguments.campaignActivity.setCampaignActivityStatus(this.getType('402828c656eafa1d0157108cbb230128'));
		}

		var emailConfig = {
			'name' = arguments.campaignActivity.getCampaignActivityName(),
			'subject' = arguments.campaignActivity.getEmailSubject(),
			'fromemaillabel' = arguments.campaignActivity.getEmailFromName(),
			'fromemailaddress' = arguments.campaignActivity.getEmailFromEmail(),
			'replytoemailaddress' = arguments.campaignActivity.getEmailReplyTo(),
			'emailStyleID' = arguments.campaignActivity.getEmailStyle(),
			'htmlContent' = arguments.campaignActivity.getEmailBodyHTML(),
			'textContent' = (isNull(arguments.campaignActivity.getEmailBodyText())) ? " " : arguments.campaignActivity.getEmailBodyText()
		};

		var emailID = '';
		var getURLs = false;

			//Create the Email in Send24 or update it if already exists
		if(isNull(arguments.campaignActivity.getSend24EmailID()) && isEmailReady(arguments.campaignActivity)) {
			emailID = getEmailService().createEmail(emailConfig);
			arguments.campaignActivity.setSend24EmailID(emailID);
			arguments.campaignActivity = this.save(arguments.campaignActivity);
			ormFlush();
			getURLs = true;
		}else if(!isNull(arguments.campaignActivity.getSend24EmailID()) && emailChanged){
			getEmailService().updateEmail(arguments.campaignActivity.getSend24EmailID(), emailConfig);
			getURLs = true;
		}

		//Get all URLs from Email Body
		if(getURLs && len(arguments.campaignActivity.getEmailBodyHTML())){
			scrapeLinks(arguments.campaignActivity.getCampaignActivityID(), arguments.campaignActivity.getEmailBodyHTML());
		}

		if(arguments.context == 'test') {
			getEmailService().sendTestEmail(emailID, arguments.data.testEmail);
		}
		return arguments.campaignActivity;
	}


	// =====================  END: Logical Methods ============================

	// ===================== START: DAO Passthrough ===========================

	// ===================== START: DAO Passthrough ===========================

	// ===================== START: Process Methods ===========================

	public any function processCampaignActivity_sendEmail(required any campaignActivity, required any processObject) {
		getService("HibachiTagService").cfsetting(requesttimeout="600000");

		campaignActivity.setRunningFlag(true);
		ormFlush();

		// Create new collection, load conllection config
		var emailRecipientsCollection = getCollectionList('Account');
		emailRecipientsCollection.setCollectionConfig(campaignActivity.getCollectionConfig());

		//run collection to retrieve accounts
		var emailRecipients = emailRecipientsCollection.getRecords();

		if(emailRecipientsCollection.getRecordsCount() == 0){
			// set status to "Sent"
			campaignActivity.setCampaignActivityStatus(this.getType('402828c656eafa1d01572e197d810197'));
			return campaignActivity;
		}
		//create mailing list
		var mailingList = getEmailService().createMailingList(campaignActivity.getAcampaignActivityName(), "Generated by Slatwall");

		var columnsName = 'emailaddress,firstname,lastname';


		//Upload Recipients
		getEmailService().addSubscribers(mailingList, emailRecipients, columnsName, '11');

		//send email

		var broadcastID = getEmailService().sendEmail(campaignActivity.getSend24EmailID(), mailingList);
		if(broadcastID){
			campaignActivity.setCampaignActivityStatus(this.getType('402828c656eafa1d01572e197d810197'));
			campaignActivity.setBroadcastID(broadcastID);
			//Snapshot of Recipients.
			getCampaignActivityAccountDAO().insertAccount(emailRecipients, campaignActivity.getCampaignActivityID());
		}
		campaignActivity.setRunningFlag(false);
		ormFlush();
	}

	// =====================  END: Process Methods ============================

	// ====================== START: Save Overrides ===========================

	// ======================  END: Save Overrides ============================

	// ==================== START: Smart List Overrides =======================

	// ====================  END: Smart List Overrides ========================

	// ====================== START: Get Overrides ============================

	// ======================  END: Get Overrides =============================

}
