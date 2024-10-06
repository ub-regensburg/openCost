=head1 NAME

EPrints::Plugin::Export::openCost

=cut

package EPrints::Plugin::Export::openCost;

use EPrints::Plugin::Export;

@ISA = ( "EPrints::Plugin::Export" );

use strict;
use Encode;

use strict;

sub new
{
        my( $class, %params ) = @_;

        my $self = $class->SUPER::new( %params );

        $self->{name} = "openCost";
        $self->{accept} = [ 'list/eprint', 'dataobj/eprint' ];
        $self->{visible} = "all";
        $self->{suffix} = ".xml";
        $self->{mimetype} = "text/xml";

        $self->{xmlns} = "https://opencost.de";
        $self->{schemaLocation} = "https://opencost.de";

        return $self;
}

sub ep_to_oa_type
{
        my( $self, $plugin, $oa_type ) = @_;
        my %types_ep_to_oa = ( #map EP OA-Types
                'primary' => 'other',
                'gold_paid' => 'APC',
                'gold_free' => 'APC',
                'gold_olh' => 'APC',
                'hybrid' => 'Hybrid-OA',
                'offsetting' => 'Offsetting',
                'rsc' => 'Offsetting',
                'alliance' => 'Permisson',
                'copyright_law' => 'Permission',
                'sherpa' => 'Permission',
                'before1994' => 'Permission',
                'indivisual_contract' => 'Permission',
                'scoap' => 'APC',
                'no_oa' => 'other',
                'unknown' => 'other',
                'other' => 'other',

        );
        return $types_ep_to_oa{ $oa_type };

}

ub ep_to_coar_type
{

        my( $plugin, $ep_type ) = @_;
        my %types_ep_to_coar_type = ( #map EP types to COAR defined types
        'article' => 'journal article',
        'book_section' => 'book part',
        'monograph' => 'book',
        'conference_item' => 'conference output',
        'book' => 'book',
        'thesis_rgbg' => 'thesis',
        'thesis' => 'thesis',
        'teaching_resource' => 'lecture',
        'video' => 'cideo',
        'image' => 'image',
        'audio' => 'sound',
        'dataset' => 'dataset',
        'experiment' => 'experimental data',
        'software' => 'software',
        'patent' => 'patent',
        'journal' => 'journal',
        'translation' => 'text',
        'contract' => 'contract',
        'other' => 'other',
        );
        
        return $types_ep_to_coar_type{ $ep_type };

}

sub ep_to_id
{
        my( $plugin, $id ) = @_;
        my %types_ep_to_id = ( 
                        'doi' =>'doi',
                        'urn' =>'urn',
                        'handle' =>'handle',
                        'purl' =>'purl',
                        'pubmed' =>'pubmed',
                        'pubmedcentral' =>'pubmedcentral',
                        'arxiv' =>'arxiv',
                        'repec' =>'repec',
                        'webofscience' =>'ut',
                        'other' =>'other',
        );
        return $types_ep_to_id{ $id };
}

sub ep_to_apc
{
        my( $plugin, $apc ) = @_;
        my %types_ep_to_apc = ( 
                        'gold_apc' =>'gold-oa',
                        'vat' =>'vat',
                        'handle' =>'colour charge',
                        'purl' =>'cover charge',
                        'pubmed' =>'hybrid-oa',
                        'pubmedcentral' =>'page charge',
                        'arxiv' =>'permission',
                        'repec' =>'publication charge',
                        'webofscience' =>'reprint',
                        'webofscience' =>'submission fee',
                        'webofscience' =>'payment fee',
                        'other' =>'other',
        );
        return $types_ep_to_apc{ $apc };
}

sub xml_dataobj
{
        my( $plugin, $eprint ) = @_;

#        my $repo = $self->{repository};

        my $openCost = $plugin->{session}->make_element(
                "opencost:data",
                "xmlns:opencost" => "https://opencost.de", 
                "xmlns:datacite" => "https://schema.datacite.org/meta/kernel-4/metadata.xsd" 
                );

        my $publication = $plugin->{session}->make_element ( "opencost:publication" );
        $openCost-> appendChild( $publication );

####################################################################
#
#      Information about the institution
#

        my $institution = $plugin->{session}->make_element (
                "opencost:institution"
                );
        $publication-> appendChild( $institution );

        my $inst_id = $plugin->{session}->make_element(
                "opencost:id"
                );      
        $institution->appendChild( $inst_id ); 
        my $inst_id_value = $plugin->{session}->make_element(
                "opencost:value"
                ); 
        $inst_id->appendChild( $inst_id_value ); 
        $inst_id_value->appendChild( $plugin->{session}->make_text ( "https://ror.org/01eezs655" ) );# $repo->get_conf("opencost", "institution_ror" ) )  );
        my $inst_id_type = $plugin->{session}->make_element(
                "opencost:type"
                );
        $inst_id->appendChild( $inst_id_type );         
        $inst_id_type->appendChild( $plugin->{session}->make_text("ror" ) );

       my $inst_name = $plugin->{session}->make_element("opencost:name");
        $institution->appendChild( $inst_name ); 
        my $inst_name_value = $plugin->{session}->make_element("opencost:value");
        $inst_name->appendChild( $inst_name_value );
        $inst_name_value->appendChild( $plugin->{session}->make_text ( "UR " ) ); # $repo->get_conf("opencost", "institution_short" ) ) );
        my $inst_name_type = $plugin->{session}->make_element("opencost:type");
        $inst_name->appendChild( $inst_name_type );
        $inst_name_type->appendChild( $plugin->{session}->make_text ( "short"  ) );

########################################################################################
#
#       primary identifier; preferably a DOI
#
         
        my $primary = $plugin->{session}->make_element("opencost:primary_identifier");
        $publication->appendChild( $primary ); 
#        if( $eprint->exists_and_set( "doi" ) )
#        {
                my $doi = $plugin->{session}->make_element("opencost:doi");
                $primary->appendChild( $doi );
                $doi->appendChild( $plugin->{session}->make_text( $eprint->get_value( "doi" ) ) );
#       }

############################################################################################
#
#      publication Type (COAR)
#

        my $publication_type = $plugin->{session}->make_element("opencost:publication_type");
        $publication->appendChild( $publication_type );

        $publication_type->appendChild( $plugin->{session}->make_text( $plugin->ep_to_coar_type( $eprint->get_value( "type" ) ) ) ) ;

###################################################################################################
#
#    Cost Data
#

        my $cost_data =  $plugin->{session}->make_element("opencost:cost_data");
        $publication->appendChild( $cost_data );

        my $invoice = $plugin->{session}->make_element("opencost:invoice");
        $cost_data->appendChild( $invoice );

        my $amount_invoice =  $plugin->{session}->make_element("opencost:amount_invoice");
        $invoice->appendChild( $amount_invoice );

        my $currency = $plugin->{session}->make_element("opencost:currency");
        $amount_invoice->appendChild( $currency );
        $currency->appendChild( $plugin->{session}->make_text( $eprint->get_value( "oa_orig_currency_type" ) ) );
        my $amount = $plugin->{session}->make_element("opencost:amount"); 
        $amount_invoice->appendChild( $amount );
        $amount->appendChild( $plugin->{session}->make_text( $eprint->get_value( "oa_orig_currency_value" ) ) );


        my $amounts_paid = $plugin->{session}->make_element("opencost:amounts_paid");
        $invoice->appendChild( $amounts_paid );

        my $costs = $eprint->get_value("costs_paid");
                foreach my $cost_data (@$costs)
                {
                my $amount_paid = $plugin->{session}->make_element("opencost:amount_paid"); 
                $amounts_paid->appendChild( $amount_paid );
                my $ap_amount = $plugin->{session}->make_element("opencost:amount"); 
                $amount_paid->appendChild( $ap_amount );
                $ap_amount->appendChild( $plugin->{session}->make_text( $cost_data->{value} ) );
                my $ap_currency = $plugin->{session}->make_element("opencost:currency"); 
                $amount_paid->appendChild( $ap_currency );
                $ap_currency->appendChild( $plugin->{session}->make_text( "EUR" ) );
                my $ap_cost_type = $plugin->{session}->make_element("opencost:cost_type"); 
                $amount_paid->appendChild( $ap_cost_type );
                $ap_cost_type->appendChild( $plugin->{session}->make_text( $plugin->ep_to_apc( $cost_data->{type}  ) ) );
                }  
                
        my $creditor = $plugin->{session}->make_element("opencost:creditor"); 
        $invoice->appendChild( $creditor );
        $creditor->appendChild( $plugin->{session}->make_text( $eprint->get_value( "publisher" ) ) );


        my $dates = $plugin->{session}->make_element("opencost:dates"); 
        $invoice->appendChild( $dates );

        my $paid = $plugin->{session}->make_element("opencost:paid"); 
        $dates->appendChild( $paid );
        $paid->appendChild( $plugin->{session}->make_text( $eprint->get_value( "oa_paid_date" ) ) );
#       my $invoice_date = $plugin->{session}->make_element("opencost:invoice"); 
#       $dates->appendChild( $invoice_date );

        my $invoice_number = $plugin->{session}->make_element("opencost:invoice_number"); 
        $invoice->appendChild( $invoice_number );
        $invoice_number->appendChild( $plugin->{session}->make_text( $eprint->get_value( "invoice_nr" ) ) );

         return $openCost;
}

sub output_dataobj
{
        my( $plugin, $dataobj ) = @_;

        my $openCost = $plugin->xml_dataobj( $dataobj );

        return EPrints::XML::to_string( $openCost );
}


1;

 



