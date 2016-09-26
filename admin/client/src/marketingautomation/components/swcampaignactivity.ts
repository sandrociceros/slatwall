/// <reference path='../../../typings/slatwallTypescript.d.ts' />
/// <reference path='../../../typings/tsd.d.ts' />

class SWCampaignActivityController{
    private object;
    private id;
    private campaignActivity;
    private campaignID;
    private campaign;
    private saving;
    private editing;
    //@ngInject
    constructor(public $hibachi,
                public observerService){
        this.init();
    }


    private init():void {
        this.campaignActivity = this.$hibachi.getCampaignActivity(this.id)['value'];
    }

    public saveCampaignActivityBasic =():void =>{
        this.saving = true;
        this.campaignActivity.$$save().then(()=>{
            this.editing = false;
        }).finally(()=>{
            this.saving = false;
        })
    };

    public saveCampaignActivity =():void =>{
        this.observerService.notify('saveNewCampaignActivity');
    };
}

class SWCampaignActivity implements ng.IDirective{

    public restrict:string = 'EA';
    public scope=true;
    public bindToController ={
        id:"@",
        campaignID:"@",
        campaignName:"@"
    };
    public controller=SWCampaignActivityController;
    public controllerAs="swCampaignActivity";

    public templateUrl;
    //@ngInject
    constructor(public marketignAutomationPartialsPath, public slatwallPathBuilder){
        this.templateUrl = this.slatwallPathBuilder.buildPartialsPath(this.marketignAutomationPartialsPath+'campaignactivity.html');
    }
    public static Factory(){
        var directive = (
            marketignAutomationPartialsPath,
            slatwallPathBuilder
        )=>new SWCampaignActivity(
            marketignAutomationPartialsPath,
            slatwallPathBuilder
        );
        directive.$inject = [
            'marketignAutomationPartialsPath',
            'slatwallPathBuilder'
        ];
        return directive;
    }

    public link:ng.IDirectiveLinkFn = (scope: ng.IScope, element: ng.IAugmentedJQuery, attrs:ng.IAttributes) =>{
    }
}
export{
    SWCampaignActivity
}