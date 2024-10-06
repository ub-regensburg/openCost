# OpenCost config file - adds new eprint fields

# values for openCost. to be set locally
$c->{opencost}{institution_ror} = "https://ror.org/XXXXXXX";
$c->{opencost}{institution_isni} = "XXXX XXXX XXXX XXXX";
$c->{opencost}{institution_ringold} = "";
$c->{opencost}{institution_short} = "XXX";
$c->{opencost}{institution_full} = "XXX XXXX";

#add new OA fields to eprint
push @{$c->{fields}->{eprint}},
{
# Field to explain, why a eprint is open access 
        name => 'oa_type',
        type => 'namedset',
        set_name => 'oa_type',
        multiple => 0,
},
{
        name => 'oa_paid_date',
        type => 'date',
        multiple => 0,
},
{
# Field for each payment 
        name => 'costs_paid',
        type => 'compound',
        fields => [
                                  {
	                            # actual payment 
                                    sub_name => 'value',
                                    type => 'float',
                                    input_cols => '8',
                                  },
                                  {
                                    # internal transaction number 
                                    sub_name => 'number',
                                    type => 'int',
                                    input_cols => '20',

                                  },
                                  {
                                    # type of payment (e.g. APC, BPC, Colour Charges) 
                                    sub_name => 'type',
                                    type => 'namedset',
                                    set_name => "costs_paid_type",
                                  },
				  {
					  sub_name => 'date_paid',
					  type => 'date',
					  min_resolution => 'year',

				  }
                            ],
        multiple => 1,
},
{
# information about the invoices (may be more than one) 
       name => 'invoice',
       type => 'compound',
       fields => [
               {
                # number written on the invoice  
                       sub_name => "value",
                        type => "float", 
                        input_boxes => 1,
                        multiple => 0,
                        sql_index => 0,
			input_cols => 8,

               },
               {
                       sub_name => "currency",
                                   type => 'set',
                                   options => [qw(
                                               GBP
                                               EUR
                                               USD
                                               CHF     
                                               )],
                       input_boxes => 1,
                       multiple => 0,
                       sql_index => 0,
               },
               {
                       # invoice number
                       sub_name => "number",
                       type => 'text',
                       input_cols => 20,
                       multiple => 0,
               },
               {
                       # date of the ionvoice
                       sub_name => "date",
                       'type' => 'date',
                       'min_resolution' => 'year',
               },
       ],
       multiple => 1,
       input_boxes => 1,
},

{
	name => 'splitted_invoice',
	type => 'set',
	options => [
		'yes',
		'no',
		'unknown',
	],
	input_style => 'medium',
	multiple => 0,
},

{
	name => 'splitted_invoice_total',
	type => 'compound',
	fields => [
	{	
		sub_name => 'value',
		type => 'float',
		  multiple => 0,
	         sql_index => 0,
	},
	{	
		sub_name => 'currency',
	        type => 'set',
	        options => [qw(
				    		GBP
						EUR
						USD
                      				CHF	
						)],
	         input_boxes => 1,
	         multiple => 0,
	         sql_index => 0,
	},
	]
},
{
        'name' => 'invoice_group',
        'type' => 'namedset',
        'set_name' => 'invoice_groups',
},



;

$c->{plugins}->{"Export::openCostXML"}->{params}->{disable} = 0;
$c->{plugins}->{"Export::openCostXML"}->{params}->{metadataPrefix} ="OpenCost";
