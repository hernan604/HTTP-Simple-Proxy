package Proxy;
use Moose;
use LWP::UserAgent;
use Data::Printer;

=head2 USAGE

Set the port for this proxy and configure your browser to use it.
Then start the proxy with perl proxy.pl

=cut

use base qw(Net::Server);
my $ua = LWP::UserAgent->new(
    agent                   => "Mozilla",
    cookie_jar              => {},
    max_redirect            => 0,
);
#you have to alter the headers. any Location: headers need to be altered to go through the proxy, at least. Set-Cookie as well
my $lines = [];
sub process_request {
    my $self = shift;
    while (<STDIN>) {
        my $line = $_;
        $line =~ s/\r\n$//;
        push @$lines, $line;
        if ( length $line == 0 || !defined $line) {
            my $req = HTTP::Request->new( );
            my $obj = HTTP::Request->parse( join( ' ', @$lines ) );
            my $response = $ua->request( $obj );
            if ( $response->is_success || $response->is_redirect ) {
              print $response->protocol." ".$response->code." ".$response->message; # EX. HTTP/1.1 200 OK
              print "\n".$response->headers->as_string;
              print "\n".$response->content if defined $response->content;
            }
            $lines = [];
            last;
        }
        last if /quit/i;
    }
}

Proxy->run(port => 9999);
