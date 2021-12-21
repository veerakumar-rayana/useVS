public class aaaaaaaaaaaaaaaa{
    public static void sendEmailTemplate(String templateName, ID ContractID, String address){
       List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
       
        EmailTemplate emailTemplate = [SELECT Id, 
                                   Subject,
                                  Body 
                                  FROM EmailTemplate
                                  WHERE DeveloperName=: templateName];
        
      	Messaging.SingleEmailMessage mail= new Messaging.SingleEmailMessage();
        mail.setTemplateId(emailTemplate.ID);      
        
    	OrgWideEmailAddress mailID =[SELECT ID FROM OrgWideEmailAddress Where Address = 'contactus@shophumm.com'];
        mail.setOrgWideEmailAddressId(mailID.ID);
        
        /*mail.setSaveAsActivity(true);*/
    
        //mail.setTreatTargetObjectAsRecipient(false);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setWhatId(ContractID);
        mail.setReplyTo('contactus@shophumm.com');
        
        String[] Addresses = new String[] {address};
       	mail.setToAddresses(Addresses);   
        mailList.add(mail);
    if(!mailList.isEmpty())
    {
        Messaging.sendEmail(mailList);
    }
    
    }
}