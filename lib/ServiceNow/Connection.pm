# ======================================================================
#
# Copyright (C) 2009 Service-now.com
#
# ======================================================================

package ServiceNow::Connection;

# default is using SOAP::Lite
use SOAP::Lite;

$VERSION = '1.00';
my $CONFIG;

=pod

=head1 Connection module

Service-now Perl API - Connection perl module

=head1 Desciption

An object representation of a Connection object used to access your Service-now instance. 
The Connection class can be overrided by the API user for implementations other than the default SOAP::Lite dependency.
To override this class, provide the subroutines for new, open, and send.

=head2 System Requirements

The Service-now Perl API requires Perl 5.8 with the following modules installed

  * SOAP::Lite (prerequisites http://soaplite.com/prereqs.html) 0.71 or later
  * Crypt::SSLeay
  * IO::Socket::SSL

=cut

# implement SOAP::Lite's basic auth strategy
sub SOAP::Transport::HTTP::Client::get_basic_credentials {
   return $CONFIG->getUserName() => $CONFIG->getUserPassword();
}

sub new {
  my ($class, $conf, $target) = (shift, shift, shift);
  # copy to global
  my $me = {};
  $CONFIG = $conf;
  
  $me->{'SOAP'} = SOAP::Lite
    -> proxy($CONFIG->getSoapEndPoint($target));
  bless($me, $class);
  return $me;
}

sub open {
  #print "connection open() is not implemented\n";
}

sub send {
  my ($me, $methodName, %hash) = (shift, shift, %{(shift)});
  
  my $METHOD = SOAP::Data->name($methodName)
    ->attr({xmlns => 'http://www.service-now.com/' . $methodName});
  
  my(@PARAMS);
  my($key);
  foreach $key (keys(%hash)) { 
  	push(@PARAMS, SOAP::Data->name($key => $hash{$key}));
  }
	
  my $RESULT = $me->{'SOAP'}->call($METHOD => @PARAMS);
  # return the element within the Body element, removing SOAP::Lite dependencies
  return $RESULT->valueof('Body');
}

sub close {
  #print "connection close() is not implemented\n";	
}

1;