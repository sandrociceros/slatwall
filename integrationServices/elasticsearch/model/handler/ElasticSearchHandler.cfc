component extends="Slatwall.org.Hibachi.HibachiEventHandler" {
	
	private any function getIntegration(){
		if(!structKeyExists(variables,'integration')){
			variables.integration = getService('integrationService').getIntegrationByIntegrationPackage('elasticsearch');
		}
		return variables.integration;
	}
	
	public void function onEvent(required any eventName, required struct eventData={}){
		
		if(structKeyExists(arguments,'entity')){
			//is this an entitysavesuccess 
			if(
				arguments.eventName=='after#arguments.entity.getClassName()#SaveSuccess' 
			){
				//index collections via bulk api
				if(arguments.entity.getClassName() == 'Collection'){
					getHibachiScope().getService('elasticSearchService').indexCollection(arguments.entity);
				}else{
					
				}
			//if delete then 
			}else if(
				arguments.eventName=='after#arguments.entity.getClassName()#DeleteSuccess' 
			){
			}
		}
		
	}
	
//	private any function deleteEntity(required any entity){
//		getIntegration().getIntegrationCFC('data').deleteEntity(argumentCollection=arguments);		
//	}
}