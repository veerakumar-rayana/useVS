@isTest
    public class TestUpdateDueDaysJob {
        
        @isTest
        public static void testCheckUpdateJob() {
            Date systemDate = Date.newInstance(2013, 03, 01);
            loan.TestHelper.systemDate = systemDate;
    

            loan.TestHelper.createSeedDataForTesting();
    

            loan__Currency__c curr = loan.TestHelper.createCurrency();
            //Create a dummy MF_Account
            loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
            loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
    

            loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
            loan.TestHelper.createDayProcessForFullYear(systemDate);
    

            loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                   dummyAccount,
                                                                   curr,
                                                                   null);
    

            Account account = new Account(Name = 'dummyAccount');
            insert account;
            Date disbursalDate = Date.newInstance(2013, 03, 01);
            
            //Create a Fee Set
            loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, null, 'Late Fees');
            dummyFee.Name = 'Late Fees';
            update dummyFee;
            
            loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
            loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
            
            loan__Org_Parameters__c orgParam = loan.CustomSettingsUtil.getOrgParameters();
            orgParam.loan__Enable_New_Spread_Option__c = true;
            upsert orgParam;
    

            //Create a dummy Loan Account
            loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
            loanAccount.loan__Account__c = account.Id;
            loanAccount.loan__Loan_Amount__c = 10000;
            loanAccount.loan__Principal_Remaining__c = 10000;
            loanAccount.loan__Number_of_Installments__c = 12;
            loanAccount.loan__Term_Cur__c = 12;
            loanAccount.loan__Fee_Set__c = dummyFeeSet.Id;
            loanAccount.loan__Disbursal_Date__c = disbursalDate;
            loanAccount.loan__Last_Disbursal_Date__c = disbursalDate;
            loanAccount.loan__Interest_Rate__c = 10;
            loanAccount.loan__Loan_Product_Name__c = dummyLP.ID;
            loanAccount.loan__Overdue_Interest_Rate__c = 12;
            loanAccount.loan__Expected_Disbursal_Date__c = disbursalDate;
            loanAccount.loan__Repayment_Procedure__c = 'Equal Monthly Installments';
            loanAccount.loan__Expected_Repayment_Start_Date__c = disbursalDate.addMonths(1).addDays(15);
            loanAccount.loan__Frequency_of_Loan_Payment__c = loan.LoanConstants.LOAN_PAYMENT_FREQ_SEMI_MONTHLY_PAY_DAY;
            loanAccount.loan__Payment_Frequency_Cycle__c = 1;
            loanAccount.loan__Grace_Period_for_Repayments__c = 0;
            loanAccount.loan__Branch__c = dummyOffice.ID;
            loanAccount.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUSACTIVE_BAD_STANDING;
            loanAccount.loan__Last_Accrual_Date__c = disbursalDate;
            loanAccount.loan__Maturity_Date_Current__c = disbursalDate.addMonths(12);
            loanAccount.loan__Next_Installment_Date__c = disbursalDate.addMonths(1).addDays(15);
            loanAccount.loan__First_Installment_Date__c = disbursalDate.addMonths(1).addDays(15);
            loanAccount.loan__Due_Day__c = 15;
            loanAccount.loan__Second_Installment_Date__c = Date.newInstance(2013, 04, 30);
            loanAccount.loan__Second_Due_Day__c = 30;
            //This will create 1 Rate schedule , so no need to create it explicitly.
            loanAccount.loan__Interest_Calculation_Method__c = loan.LoanConstants.REPAYMENT_INT_CALC_METHOD_FLEXIBLE_REPAYMENT;
            insert loanAccount;
            
            loanAccount = [SELECT Id,
                                  loan__First_Installment_Date__c,
                                  loan__Due_Day__c,
                                  loan__Second_Installment_Date__c,
                                  loan__Second_Due_Day__c
                           FROM loan__Loan_Account__c
                          ];
            system.assertEquals(15, loanAccount.loan__Due_Day__c);
            system.assertEquals(30, loanAccount.loan__Second_Due_Day__c);
            
            Test.StartTest();
            
            UpdateDueDaysJob job = new UpdateDueDaysJob();
            Database.executeBatch(job);
            
            Test.StopTest();
            
            loanAccount = [SELECT Id,
                                  loan__First_Installment_Date__c,
                                  loan__Due_Day__c,
                                  loan__Second_Installment_Date__c,
                                  loan__Second_Due_Day__c
                           FROM loan__Loan_Account__c
                          ];
            system.assertEquals(15, loanAccount.loan__Due_Day__c);
            system.assertEquals(31, loanAccount.loan__Second_Due_Day__c);
        }
        
    }