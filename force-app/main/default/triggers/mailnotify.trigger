trigger mailnotify on loan__Loan_Account__c(After update) {
    loan__Loan_Account__c cl = trigger.new[0]; 
    
    if (Trigger.IsUpdate) { 
        if(cl.loan__Last_Transaction_Type__c=='Reschedule') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            EmailTemplate emailTemp = [SELECT Id, 
                                       Subject,
                                       Body 
                                       FROM EmailTemplate
                                       WHERE DeveloperName= 'Balance_cleared_Refund_due'];
            
            mail.setTemplateId(emailTemp.Id);
            mail.setOrgWideEmailAddressId('0D25j000000GmcmCAC');
            mail.setSaveAsActivity(true);
            mail.SetWhatId(cl.Id);
            mail.setTargetObjectId(cl.loan__Contact__c);
            
            mail.setBccAddresses(new List<String>{'veerakumar.rayana@q2.com'});
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            
        } }}