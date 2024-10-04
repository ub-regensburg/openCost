#
# Contract Dataset
#

# dataset
$c->{datasets}->{contract} = {
 	class => "EPrints::DataObj::Contract",
 	sqlname => "contract",
 	datestamp => "datestamp",
	index => 1,
};

# fields
for(
 	{
		# internal ID
 		name => "contractid",
 		type => "counter",
 		sql_counter => "contractid",
 	},
        {
		# user who created the Contract object
		name => "userid",
		type => "itemref",
		datasetid => "user",
	},
       {
                # creation date
                name => "datestamp",
                type => "timestamp",
        },
       {
                name => "esac_id",
                type => "text",
                input_cols => 15,
        },
        {
                name => "ezb_id",
                type => "text",
                input_cols => 15,
        },
	{ 
		name => "info",
                type => "longtext",
	},


	#   { name=>"documents", type=>"subobject", datasetid=>'document',
	#       multiple=>1, text_index=>1, dataobj_fieldname=>'contractidid' },
	#
	#{ name=>"files", type=>"subobject", datasetid=>"file",
	#        multiple=>1 },



	{
		# the literal name of the contract
 		name => "name",
 		type => "text",
 	},
	{
		name => "primary_identifier",
		type => "text",
	},
	{
		name => "participation",
		type => "compound",
		fields => [
			{
			sub_name => "from",
			type =>  "date",
		},
		{
			sub_name => "to",
			type => "date",
		},	
		]
	},

	{
		name => 'invoice',
       	     	type => 'compound',
       		fields => [
			{
				sub_name => "number",
				type => "text",
				input_cols => 10,
			},
			{
				sub_name => "creditor",
				type => "text",
				input_cols => 10,
			},
			{
				sub_name => "from",
				type =>  "date",
			},
						{
				sub_name => "to",
				type =>  "date",
			},
			{
				sub_name  => "amount",
				type => "float",
				input_cols => 9,
			},
			{
				sub_name => "currency",
				type => "namedset",
				set_name => "currencies",
			},
		],
		multiple => 1,

	},
	{
		name => 'payments',
       	     	type => 'compound',
       		fields => [
			{ 	sub_name  => "invoice",
				type => "text",
			},

			{ 	sub_name  => "amount",
				type => "float",
			},
			{
				sub_name => "currency",
				type => "namedset",
				set_name => "currencies",
			},
			{ 	sub_name  => "type",
				type => "namedset",
				set_name => "contract_payment_types",
			},




		],
		multiple => 1,
	},



)

{
	$c->add_dataset_field('contract', $_, reuse => 1);
}


{
	package EPrints::DataObj::Contract;

	our @ISA = qw( EPrints::DataObj );

	sub contract_with_name
	{
		my ($repo, $name) = @_;

		return $repo->dataset('contract')->search(filters => [
			{ meta_fields => [qw( name )], value => $name, match => 'EX' }
		])->item(0);
	}

	#sub get_all_documents
	#{
	#	my( $self ) = @_;

	#	my @docs;

	# Filter out any documents that are volatile versions
	#	foreach my $doc (@{($self->value( "documents" ))})
	#	{
		#	next if $doc->has_relation( undef, "isVolatileVersionOf" );
		#	push @docs, $doc;
		#	}

		#	my @sdocs = sort { ($a->get_value( "placement" )||0) <=> ($b->get_value( "placement" )||0) || $a->id <=> $b->id } @docs;
		#	return @sdocs;
		#}




	sub get_system_field_info
	{
		my( $class ) = @_;

		return ();
	}
	
	sub get_dataset_id { 'contract' }

	sub has_owner
	{
		my ($self, $user) = @_;

		return $self->is_set('userid') && $self->value('userid') eq $user->id;
	}

# fields to search on the UI
	$c->{datasets}->{contract}->{search}->{dataobjref} = {
                search_fields => [{
                        id => "q",
                        meta_fields => [qw/ name info esac_id ezb_id /],
                        match => "IN",
                }],
                show_zero_results => 1,
                order_methods => {
                        byid => "contract_id",
                        bytime => "participation_from", 
                },
                default_order => "byid",
};


}

#user roles
#just admin can view

push @{$c->{user_roles}->{admin}}, qw{
        +contract/create
        +contract/details
        +contract/edit
        +contract/view
        +contract/destroy
        +contract/export
	+contract/search
};


# back reference to a contract
$c->add_dataset_field( 'eprint',
        {
                name => "contracts",
                type=>"dataobjref",
                datasetid=>"contract",
		multiple => 1,
                fields => [
                        { sub_name => 'name', type => "text" },
                ],
        },
        reuse => 1
);


# fields to search on the UI
$c->{datasets}->{contract}->{search}->{dataobjref} = {
                search_fields => [{
                        id => "q",
                        meta_fields => [qw/ name  /],
                        match => "IN",
                }],
                show_zero_results => 1,
                order_methods => {
                        byid => "contractid",
                },
                default_order => "byid",
};
