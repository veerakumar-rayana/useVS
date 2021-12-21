/**
 * Following Controller Help in creating the Trial Org for Q2 Lending Products
 * 
 */
public without sharing  class NewTrialSignupController {

    public Lead newLead {set; get;}
    public String templateId {set; get;} // 0TT3t000003B8Oc
    public List<SelectOption> templateOptions {set; get;}
    public List<SelectOption> countryCodes {set; get;}

    public NewTrialSignupController() {
        // Initializing the required variables
        newLead = new Lead();
        templateOptions = new List<SelectOption>();
        templateOptions.add(new SelectOption(String.valueOf('--None--'), String.valueOf('--None--')));
        // Create Templaes List 
        List<Trial_Org_Template__c> templateList = [Select Id,Name, Trial_Org_Template_Name__c, Trial_Org_Template_ID__c From Trial_Org_Template__c];
        system.debug('templateList'+templateList);
        for(Trial_Org_Template__c template : templateList) {
            templateOptions.add(new SelectOption(template.Trial_Org_Template_ID__c, template.Trial_Org_Template_Name__c));
        }

        countryCodes = new List<SelectOption>();
        Map<String, String> countryCodeNamesMap = getCountryCodeNamesMap();
        for(String countryCode : countryCodeNamesMap.keySet()) {
            countryCodes.add(new SelectOption(countryCode, countryCodeNamesMap.get(countryCode)));
        }

        cllease_tso_template__c template1 = [SELECT template_Id__c FROM cllease_tso_template__c LIMIT 1];
        // hard coding template for now
        system.debug('template1'+template1);
        templateId = template1.template_Id__c;
    }

    public PageReference createTrialOrg() {
        validateDetails();
        try {
            // Inserting the new Lead
            upsert newLead;

            // Creating Trial Org Using SignupRequest
            SignupCreation sc = new SignupCreation();
            sc.createNewTrial(newLead, templateId);
        } catch (DmlException e) {
            system.debug(e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Request Failed with Message: '+e.getMessage()));
            return null;
        }
        
        // Redirecting to Successful message page on raising request
        PageReference ref = new PageReference('/apex/thankYouPage');
        ref.setRedirect(true);
        return ref;
    }

    private void validateDetails() {
        System.debug(' newlead: '+newLead);
        System.debug(' TemplateID: '+templateId);
        // Check for Lead details
        if(newLead.FirstName == null){
            throw new AuraHandledException('FirstName is required for Trail Org Creation.');
        }
        if(newLead.LastName == null){
            throw new AuraHandledException('LastName is required for Trail Org Creation.');
        }
        if(newLead.Email == null){
            throw new AuraHandledException('Email is required for Trail Org Creation.');
        }
        if(newLead.Country == null){
            throw new AuraHandledException('Country is required for Trail Org Creation.');
        }
        if(newLead.Company == null){
            throw new AuraHandledException('Company is required for Trail Org Creation.');
        }
        // Check for template assignment.
        if(templateId == null) {
            throw new AuraHandledException('Please Select Template for Trail Org Creation.');
        }
    }

    private static String getUserName(Lead newLead) {
        
        String firstName = newLead.FirstName;
        String lastName = newLead.LastName;
        Integer existingNoOfLogins = 0;
        
        AggregateResult groupedResults = [SELECT COUNT(ID) nooflogins
                                                FROM signupRequest
                                                WHERE Status = 'Success'];
        if(groupedResults.get('nooflogins') != null){
            existingNoOfLogins = (Integer)groupedResults.get('nooflogins');
        }
        
        String userName = newLead.FirstName +'.'+ newLead.LastName +'@'+ existingNoOfLogins+ 'clleasetrialforce.com';
        
        return userName.replaceAll(' ', '');   
    }
   
    // this is inner class without sharing , so runs in system context
    // this is only to handle the SignupRequest call since it cant be call by unauth user
    public without sharing class SignupCreation {
        public void createNewTrial(Lead newLead, String templateId) {
            SignupRequest sr = new SignupRequest();
            sr.FirstName = newLead.FirstName;
            sr.LastName = newLead.LastName;
            sr.SignupEmail = newLead.Email;
            sr.TemplateId = templateId;
            sr.Country = newLead.Country;
            sr.Company = newLead.Company;
            sr.Username = getUserName(newLead);
            sr.TrialDays = 365;
                        
            try {
                upsert sr;
            } catch (Exception e) {
                system.debug(e);
                throw new AuraHandledException('Error with Signup Request: '+ e.getMessage());
            }
        }
    }

    private Map<String, String> getCountryCodeNamesMap() {
        return new Map<String, String> {
            'US'=>  'United States',            'AF'=>  'Afghanistan',          'AL'=>  'Albania', 
            'DZ'=>  'Algeria',                  'AS'=>  'American Samoa',       'AD'=>  'Andorra', 
            'AI'=>  'Anguilla',                 'AQ'=>  'Antarctica',           'AG'=>  'Antigua And Barbuda', 
            'AR'=>  'Argentina',                'AM'=>  'Armenia',              'AW'=>  'Aruba', 
            'AU'=>  'Australia',                'AT'=>  'Austria',              'AZ'=>  'Azerbaijan',  
            'BS'=>  'Bahamas, The',             'BH'=>  'Bahrain',              'BD'=>  'Bangladesh',  
            'BB'=>  'Barbados',                 'BY'=>  'Belarus',              'BZ'=>  'Belize',      
            'BE'=>  'Belgium',                  'BJ'=>  'Benin',                'BM'=>  'Bermuda',     
            'BT'=>  'Bhutan',                   'BO'=>  'Bolivia',              'BV'=>  'Bouvet Is',   
            'BA'=>  'Bosnia and Herzegovina',   'BW'=>  'Botswana',             'BR'=>  'Brazil',      
            'IO'=>  'British Indian Ocean Territory',       'BN'=>  'Brunei',   'BG'=>  'Bulgaria',    
            'BF'=>  'Burkina Faso',             'BI'=> 'Burundi',               'KH'=>  'Cambodia',    
            'CM'=>  'Cameroon',                 'CA'=>  'Canada',               'CV'=>  'Cape Verde',  
            'KY'=>  'Cayman Is',                'CF'=>  'Central African Republic',  'TD'=>  'Chad',        
            'CL'=>  'Chile',                    'CN'=>  'China',                'HK'=>  'Hong Kong',   
            'MO'=>  'Macau',                    'CX'=>  'Christmas Is',         'CC'=>  'Cocos (Keeling) Is',                
            'CO'=>  'Colombia',                 'KM'=>  'Comoros',              'CK'=>  'Cook Islands',                      
            'CR'=>  'Costa Rica',               'CI'=>  'Cote Ivoire (Ivory Coast)',   'HR'=>  'Croatia (Hrvatska)',                
            'CY'=>  'Cyprus',                   'CZ'=>  'Czech Republic',       'CD'=>  'Democratic Republic of the Congo',  
            'DK'=>  'Denmark',                  'DM'=>  'Dominica',             'DO'=>  'Dominican Republic',                
            'DJ'=>  'Djibouti',                 'TL'=>  'Timor-Leste',          'EC'=>  'Ecuador',     
            'EG'=>  'Egypt',                    'SV'=>  'El Salvador',          'GQ'=>  'Equatorial Guinea',                 
            'ER'=>  'Eritrea',                  'EE'=>  'Estonia',              'ET'=>  'Ethiopia',    
            'FK'=>  'Falkland Is (Is Malvinas)','FO'=>  'Faroe Islands',        'FJ'=>  'Fiji Islands',                      
            'FI'=>  'Finland',                  'FR'=>  'France',               'GF'=>  'French Guiana',                     
            'PF'=>  'French Polynesia',         'TF'=>  'French Southern Territories',    'MK'=>  'F.Y.R.O. Macedonia',                
            'GA'=>  'Gabon',                    'GM'=>  'Gambia,  The',         'GE'=>  'Georgia',     
            'DE'=>  'Germany',                  'GH'=>  'Ghana',                'GI'=>  'Gibraltar',   
            'GR'=>  'Greece',                   'GL'=>  'Greenland',            'GD'=>  'Grenada',     
            'GP'=>  'Guadeloupe',               'GU'=>  'Guam',                 'GT'=>  'Guatemala',   
            'GN'=>  'Guinea',                   'GW'=>  'Guinea-Bissau',        'GY'=>  'Guyana',      
            'HT'=>  'Haiti',                    'HM'=>  'Heard and McDonald Is','HN'=>  'Honduras',    
            'HU'=>  'Hungary',                  'IS'=>  'Iceland',              'IN'=>  'India',       
            'ID'=>  'Indonesia',                'IE'=>  'Ireland',              'IL'=>  'Israel',      
            'IT'=>  'Italy',                    'JM'=>  'Jamaica',              'JP'=>  'Japan',       
            'JO'=>  'Jordan',                   'KZ'=>  'Kazakhstan',           'KE'=>  'Kenya',       
            'KI'=>  'Kiribati',                 'KR'=>  'Korea=>  South',       'KW'=>  'Kuwait',      
            'KG'=>  'Kyrgyzstan',               'LA'=>  'Laos',                 'LV'=>  'Latvia',      
            'LB'=>  'Lebanon',                  'LS'=>  'Lesotho',              'LR'=>  'Liberia',     
            'LI'=>  'Liechtenstein',            'LT'=>  'Lithuania',            'LU'=>  'Luxembourg',  
            'MG'=>  'Madagascar',               'MW'=>  'Malawi',               'MY'=>  'Malaysia',    
            'MV'=>  'Maldives',                 'ML'=>  'Mali',                 'MT'=>  'Malta',       
            'MH'=>  'Marshall Is',              'MR'=>  'Mauritania',           'MU'=>  'Mauritius',   
            'MQ'=>  'Martinique',               'YT'=>  'Mayotte',              'MX'=>  'Mexico',      
            'FM'=>  'Micronesia',               'MD'=>  'Moldova',              'MC'=>  'Monaco',      
            'MN'=>  'Mongolia',    'MS'=>  'Montserrat',  'MA'=>  'Morocco',     'MZ'=>  'Mozambique',  'MM'=>  'Myanmar',     'NA'=>  'Namibia',     'NR'=>  'Nauru',       'NP'=>  'Nepal',       'NL'=>  'Netherlands,  The','AN'=>  'Netherlands Antilles', 'NC'=>  'New Caledonia', 'NZ'=>  'New Zealand', 'NI'=>  'Nicaragua',   'NE'=>  'Niger',       'NG'=>  'Nigeria',     'NU'=>  'Niue',        'NO'=>  'Norway',      'NF'=>  'Norfolk Island','MP'=>  'Northern Mariana Is','OM'=>  'Oman',        'PK'=>  'Pakistan',    'PW'=>  'Palau',       'PA'=>  'Panama',      'PG'=>  'Papua new Guinea',                  
            'PY'=>  'Paraguay',    'PE'=>  'Peru',        'PH'=>  'Philippines', 'PN'=>  'Pitcairn Island',  'PL'=>  'Poland',      'PT'=>  'Portugal',    'PR'=>  'Puerto Rico', 'QA'=>  'Qatar',       'CG'=>  'Republic of the Congo', 'RE'=>  'Reunion',     'RO'=>  'Romania',     'RU'=>  'Russia',      'SH'=>  'Saint Helena','KN'=>  'Saint Kitts And Nevis',             
            'LC'=>  'Saint Lucia', 'PM'=>  'Saint Pierre and Miquelon', 'VC'=>  'Saint Vincent And The Grenadines', 'WS'=>  'Samoa',       'SM'=>  'San Marino',  'ST'=>  'Sao Tome and Principe',             
            'SA'=>  'Saudi Arabia','SN'=>  'Senegal',     'SC'=>  'Seychelles',  'SL'=>  'Sierra Leone', 'SG'=>  'Singapore',   'SK'=>  'Slovakia',    'SI'=>  'Slovenia',    'SB'=>  'Solomon Islands',                   
            'SO'=>  'Somalia',     'ZA'=>  'South Africa', 'GS'=>  'South Georgia', 'ES'=>  'Spain',       'LK'=>  'Sri Lanka',   'SR'=>  'Suriname',    'SJ'=>  'Svalbard And Jan Mayen Is', 'SZ'=>  'Swaziland',   'SE'=>  'Sweden',      'CH'=>  'Switzerland', 'TW'=>  'Taiwan',      'TJ'=>  'Tajikistan',  'TZ'=>  'Tanzania',    'TH'=>  'Thailand',    'TG'=>  'Togo',        'TK'=>  'Tokelau',     'TO'=>  'Tonga',       'TT'=>  'Trinidad And Tobago', 'TN'=>  'Tunisia',     'TR'=>  'Turkey',      'TC'=>  'Turks And Caicos Is',  'TM'=>  'Turkmenistan',                      
            'TV'=>  'Tuvalu',      'UG'=>  'Uganda',      'UA'=>  'Ukraine',     'AE'=>  'United Arab Emirates','GB'=>  'United Kingdom', 'UM'=>  'United States Minor Outlying Is', 'UY'=>  'Uruguay',     'UZ'=>  'Uzbekistan',  'VU'=>  'Vanuatu',     'VA'=>  'Vatican City State (Holy See)','VE'=>  'Venezuela',   'VN'=>  'Vietnam',     'VG'=>  'Virgin Islands (British)', 'VI'=>  'Virgin Islands (US)',               
            'WF'=>  'Wallis And Futuna Islands', 'EH'=>  'Western Sahara','YE'=>  'Yemen',       'ZM'=>  'Zambia',      'ZW'=>  'Zimbabwe'
        };
    }
}