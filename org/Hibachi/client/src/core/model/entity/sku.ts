/// <reference path='../../../../typings/hibachiTypescript.d.ts' />
/// <reference path='../../../../typings/tsd.d.ts' />


import {BaseEntity} from "./baseentity";

declare var angular:any;
class Sku extends BaseEntity{

    public newQOH; 

    constructor($injector){
        super($injector);
    }


}
export {
    Sku
}