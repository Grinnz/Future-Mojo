package Future::Mojo;

use strict;
use warnings;
use Carp 'croak';

use parent 'Future';

our $VERSION = '0.001';

sub new {
	my $proto = shift;
	my $self = $proto->SUPER::new;
	
	$self->{loop} = ref $proto ? $proto->{loop} : shift;
	
	return $self;
}

sub loop { shift->{loop} }

sub await { shift->{loop}->one_tick }

sub done_next_tick {
	my $self = shift;
	my @result = @_;
	
	$self->loop->next_tick(sub { $self->done(@result) });
	
	return $self;
}

sub fail_next_tick {
	my $self = shift;
	my ($exception, @details) = @_;
	
	croak 'Expected a true exception' unless $exception;
	
	$self->loop->next_tick(sub { $self->fail($exception, @details) });
	
	return $self;
}

1;

=head1 NAME

Future::Mojo - use Future with Mojo::IOLoop

=head1 SYNOPSIS

 use Future::Mojo;
 use Mojo::IOLoop;
 
 my $loop = Mojo::IOLoop->new;
 
 my $future = Future::Mojo->new($loop);
 
 $loop->timer(3 => sub { $future->done('Done') });
 
 print $future->get, "\n";

=head1 DESCRIPTION

This subclass of L<Future> stores a reference to the associated L<Mojo::IOLoop>
instance, allowing the C<await> method to block until the Future is ready.

For a full description on how to use Futures, see the L<Future> documentation.

=head1 METHODS

L<Future::Mojo> inherits all methods from L<Future> and implements the
following new ones.

=head2 loop

 $loop = $future->loop;

Returns the underlying L<Mojo::IOLoop> object.

=head2 await

 $future->await until $future->is_ready;

Runs an iteration of the underlying L<Mojo::IOLoop>.

=head2 done_next_tick

 $future = $future->done_next_tick(@result);

A shortcut to calling the C<Future/"done"> method in a
L<Mojo::IOLoop/"next_tick"> on the underlying L<Mojo::IOLoop>. Ensures that a
returned Future object is not ready immediately, but will wait for the next IO
round.

=head2 fail_next_tick

 $future = $future->fail_next_tick($exception, @details);

A shortcut to calling the L<Future/"fail"> method in a
L<Mojo::IOLoop/"next_tick"> on the underlying L<Mojo::IOLoop>. Ensures that a
returned Future object is not ready immediately, but will wait for the next IO
round.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Future>
