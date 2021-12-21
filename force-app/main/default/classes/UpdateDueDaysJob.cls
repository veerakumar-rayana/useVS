global class UpdateDueDaysJob extends clcommon.DynamicJob {
        global static String jobName = 'UPDATE DUE DAYS';
        
        global UpdateDueDaysJob() {
            super(jobName, getQuery());
        }
        
        global override void doInitialize() {} // do nothing
        
        global override String getRuntimeQuery() {
            return getQuery();
        }
        
        global static String getQuery() {
            String allowabledLoanStatuses = '\'' + loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING + '\'' + ',' +
                    '\''+ loan.LoanConstants.LOAN_STATUSACTIVE_BAD_STANDING + '\'' + ',' +
                    '\''+ loan.LoanConstants.LOAN_STATUS_ACTIVE_MATURED + '\'';
    

            String ns = 'loan';
            mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
            mfiflexUtil.ObjectCache loanOC ;
            loanOC = ec.getObject('LoansJob');
            if ( loanOC != null) {
                ec.deleteObject('LoansJob');
            }
            loanOC = ec.createObject('LoansJob',
                    'Loan_Account__c',
                    ns);
            String fields = 'Id, ' +
                            'First_Installment_Date__c, ' +
                            'Second_Installment_Date__c, ' +
                            'Due_Day__c, ' +
                            'Second_Due_Day__c ';
            loanOC.addFields(fields);
            loanOC.addNamedParameter('frequency', loan.LoanConstants.LOAN_PAYMENT_FREQ_SEMI_MONTHLY_PAY_DAY);
            String whereClause = 'Loan_Status__c in (' + allowabledLoanStatuses + ')'
                                 + ' AND Invalid_Data__c = false AND Frequency_of_Loan_Payment__c = :frequency';
    

            loanOC.setWhereClause(whereClause);
            String query = loanOC.buildQuery().getQuery();
            system.debug('query :: ' + query);
            return query;
        }
        
        global override String getRuntimeQueryForPipelinedExecution(Set<Id> records) {
            return null;
        }
        
        global override void doStart(Database.BatchableContext bc) {}
    

        global override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
            List<loan__Loan_Account__c> loanAccountList = (List<loan__Loan_Account__c>) scope;
            
            for (loan__Loan_Account__c loanAccount : loanAccountList) {
                Boolean firstPaymentDatelastDay = false;
                Boolean secondPaymentDatelastDay = false;
                
                if(loanAccount.loan__First_Installment_Date__c != null && loanAccount.loan__Due_Day__c != null) {
                    Date firstPaymentDate = loanAccount.loan__First_Installment_Date__c;
                    firstPaymentDatelastDay = (firstPaymentDate == firstPaymentDate.toStartOfMonth().addDays(
                                               Date.daysInMonth(firstPaymentDate.toStartOfMonth().year(), firstPaymentDate.toStartOfMonth().month()) - 1))
                                               ? true : false;
                }
                
                if(loanAccount.loan__Second_Installment_Date__c != null && loanAccount.loan__Second_Due_Day__c != null) {
                    Date secondPaymentDate = loanAccount.loan__Second_Installment_Date__c;
                    secondPaymentDatelastDay = (secondPaymentDate == secondPaymentDate.toStartOfMonth().addDays(
                                                Date.daysInMonth(secondPaymentDate.toStartOfMonth().year(), secondPaymentDate.toStartOfMonth().month()) - 1))
                                                ? true : false;
                }
                
                //If first payment is falling on last day of the month then we are updating the due day to 31.
                if(firstPaymentDatelastDay) {
                    loanAccount.loan__Due_Day__c = 31;
                }
                //If second payment is falling on last day of the month then we are updating the due day to 31.
                if(secondPaymentDatelastDay) {
                    loanAccount.loan__Second_Due_Day__c = 31;
                }
            }
            
            update loanAccountList;
        }
        
        global override void doFinish(Database.BatchableContext bc) {}
    }