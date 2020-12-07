({
    execute : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url" : 'apex/EFormManualEntry?id=5001f0000014Nn6AAE'
        })
        urlEvent.fire();
    }
});