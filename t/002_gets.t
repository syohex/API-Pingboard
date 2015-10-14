use strict;
use warnings;
use API::Pingboard;
use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;
#Log::Log4perl->easy_init($WARN);
Log::Log4perl->easy_init($DEBUG);
use YAML;

if( not $ENV{PINGBOARD_ACCESS_TOKEN} ){
    plan skip_all => "!!! Environment variable PINGBOARD_ACCESS_TOKEN was not defined, so live tests not being executed !!!";
}

# Setting more aggressive timeout/backoff/retries so that testing does not take forever
my $p = API::Pingboard->new(
    access_token    => $ENV{PINGBOARD_ACCESS_TOKEN},
    timeout         => 5,
    default_backoff => 2,
    max_tries       => 1,
    );

my @users;
# Test get_users method
if( not $ENV{TEST_API_PINGBOARD_SKIP_GET_USERS} ){
    try{
        # Get a list of users
        @users = $p->get_users( size => 1 );
        diag( "Got " . scalar( @users ) . " users using the get_users method" );
        ok( scalar( @users ) > 0, "get_users: list" );

        # Select a random user id from the list of users
        my $user_from_list = $users[ int( rand( $#users ) ) ];

        # Get a single user by id
        diag( "Getting user by id: " . $user_from_list->{id} );
        my( $user ) = $p->get_users( id => $user_from_list->{id} );
        is( $user->{id}, $user_from_list->{id}, "get_users: single id" );
    }catch{
        fail( "get_users:\n$_\nTo disable this test set environment TEST_API_PINGBOARD_SKIP_GET_USERS=1" )
    };
}

# Test get_groups method
if( not $ENV{TEST_API_PINGBOARD_SKIP_GET_GROUPS} ){
    try{
        # Get list of groups
        my @groups = $p->get_groups( size => 1 );
        diag( "Got " . scalar( @groups ) . " groups using the get_groups method" );
        ok( scalar( @groups ) > 0, "get_groups: list" );

        # Select a random group id from the list of groups
        my $group_from_list = $groups[ int( rand( $#groups ) ) ];

        # Get a single group by id
        diag( "Getting group by id: " . $group_from_list->{id} );
        my( $group ) = $p->get_groups( id => $group_from_list->{id} );
        is( $group->{id}, $group_from_list->{id}, "get_groups: single id" );
    }catch{
        fail( "get_groups:\n$_\nTo disable this test set environment TEST_API_PINGBOARD_SKIP_GET_GROUPS=1" )
    };
}

# Test get_custom_fields
# !!! get_custom_fields api always responds with a 500 error...
# This test is disable by default for now until this bug is fixed
if( 0 and not $ENV{TEST_API_PINGBOARD_SKIP_GET_CUSTOM_FIELDS} ){
    try{
        my @custom_fields = $p->get_custom_fields( size => 1 );
        diag( "Got " . scalar( @custom_fields ) . " custom_fields using the get_custom_fields method" );
        ok( scalar( @custom_fields ) > 0, "custom_field: list" );

        # Select a random custom_field id from the list of custom_fields
        my $custom_field_from_list = $custom_fields[ int( rand( $#custom_fields ) ) ];

        # Get a single custom_field by id
        diag( "Getting custom_field by id: " . $custom_field_from_list->{id} );
        my( $custom_field ) = $p->get_custom_fields( id => $custom_field_from_list->{id} );
        is( $custom_field->{id}, $custom_field_from_list->{id}, "custom_field: single id" );
    }catch{
        fail( "custom_fields:\n$_\nTo disable this test set environment TEST_API_PINGBOARD_SKIP_GET_CUSTOM_FIELDS=1" )
    };
}

# Test get_linked_accounts
if( not $ENV{TEST_API_PINGBOARD_SKIP_GET_LINKED_ACCOUNTS} ){
    try{
        # Using the array of users from above, look for one which has linked_accounts
        if( scalar( @users ) == 0 ){
            diag( "!!! Cannot test get_linked_accounts because no users found !!!" );
        }else{
            # Get one linked_accounts_id from the first user which has one.
            my $linked_accounts_id = undef;
            foreach my $user ( @users ){
                if( $user->{links}{linked_accounts} and scalar( @{ $user->{links}{linked_accounts} } ) > 0 ){
                    $linked_accounts_id = $user->{links}{linked_accounts}[0];
                    last;
                }
            }
            if( not $linked_accounts_id ){
                fail( "linked_accounts: Cannot test get_linked_accounts because no linked_accounts_id found in any of the users" );
            }else{
                my( $linked_account ) = $p->get_linked_accounts( id => $linked_accounts_id );
                ok( $linked_account, "linked_accounts: single id" );
            }
        }
    }catch{
        fail( "linked_accounts:\n$_\nTo disable this test set environment TEST_API_PINGBOARD_SKIP_GET_LINKED_ACCOUNTS=1" )
    };
}

# Test get_linked_account_providers
if( not $ENV{TEST_API_PINGBOARD_SKIP_GET_LINKED_ACCOUNT_PROVIDERS} ){
    try{
        my @linked_account_providers = $p->get_linked_account_providers( size => 1 );
        diag( "Got " . scalar( @linked_account_providers ) . " linked_account_providers" );
        ok( scalar( @linked_account_providers ) > 0, "get_linked_account_providers: list" );

        # Select a random custom_field id from the list of linked_account_providers
        my $linked_account_provider_from_list = $linked_account_providers[ int( rand( $#linked_account_providers ) ) ];

        # Get a single linked_account_provider by id
        diag( "Getting linked_account_provider by id: " . $linked_account_provider_from_list->{id} );
        my( $linked_account ) = $p->get_linked_account_providers( id => $linked_account_provider_from_list->{id} );
        is( $linked_account->{id}, $linked_account_provider_from_list->{id}, "linked_account_providers: single id" );
    }catch{
        fail( "linked_account_providers:\n$_\nTo disable this test set environment TEST_API_PINGBOARD_SKIP_GET_LINKED_ACCOUNT_PROVIDERS=1" )
    };
}

# Test get_statuses
if( not $ENV{TEST_API_PINGBOARD_SKIP_GET_STATUSES} ){
    try{
        my @statuses = $p->get_statuses( size => 1 );
        diag( "Got " . scalar( @statuses ) . " statuses" );
        ok( scalar( @statuses ) > 0, "get_statuses: list" );

        # Select a random custom_field id from the list of statuses
        my $status_from_list = $statuses[ int( rand( $#statuses ) ) ];

        # Get a single status by id
        diag( "Getting status by id: " . $status_from_list->{id} );
        my( $linked_account ) = $p->get_statuses( id => $status_from_list->{id} );
        is( $linked_account->{id}, $status_from_list->{id}, "statuses: single id" );
    }catch{
        fail( "statuses:\n$_\nTo disable this test set environment TEST_API_PINGBOARD_SKIP_GET_STATUSES=1" )
    };
}

done_testing();
exit(0);
