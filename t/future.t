use strict;
use warnings;

BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll' }

use Test::More;
use Test::Identity;

use Mojo::IOLoop;
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

# new_timer
{
	my $future = Future::Mojo->new_timer($loop, 0.1);
	
	$future->await until $future->is_ready;
	ok $future->is_ready, '$future is ready from new_timer';
	is_deeply [$future->get], [], '$future->get returns empty list on new_timer';
}

# timer cancellation
{
	my $called;
	my $future = Future::Mojo->new_timer($loop, 0.1)->on_done(sub { $called++ });
	
	$future->cancel;
	
	Future::Mojo->new_timer($loop, 0.3)->get;
	
	ok !$called, '$future->cancel cancels a pending timer';
}

done_testing;
