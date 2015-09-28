use strict;
use warnings;

BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll' }

use Test::More;
use Test::Identity;

use Mojo::IOLoop;

use Future;
use Future::Mojo;

my $loop = Mojo::IOLoop->new;

{
	my $future = Future::Mojo->new($loop);
	
	identical $future->loop, $loop, '$future->loop yields $loop';
	
	$loop->next_tick(sub { $future->done('result') });
	
	is_deeply [$future->get], ['result'], '$future->get on Future::Mojo';
}

# done_next_tick
{
	my $future = Future::Mojo->new($loop);
	
	identical $future->done_next_tick('deferred result'), $future, '->done_next_tick returns $future';
	ok !$future->is_ready, '$future not yet ready after ->done_next_tick';
	
	is_deeply [$future->get], ['deferred result'], '$future now ready after ->get';
}

# fail_next_tick
{
	my $future = Future::Mojo->new($loop);
	
	identical $future->fail_next_tick("deferred exception\n"), $future, '->fail_next_tick returns $future';
	ok !$future->is_ready, '$future not yet ready after ->fail_next_tick';
	
	$future->await until $future->is_ready;
	
	is_deeply [$future->failure], ["deferred exception\n"], '$future now ready after $future->await';
}

done_testing;
