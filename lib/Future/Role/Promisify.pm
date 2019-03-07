package Future::Role::Promisify;

use Mojo::Promise;
use Role::Tiny;

our $VERSION = '1.000';

requires qw(on_done on_fail);

sub promisify {
  my $self = shift;
  my $p = Mojo::Promise->new;
  $p->ioloop($self->loop) if $self->isa('Future::Mojo');
  $self->on_done(sub { $p->resolve(@_) })
       ->on_fail(sub { $p->reject(@_) })->retain;
  return $p;
}

1;

=head1 NAME

Future::Role::Promisify - Chain a Mojo::Promise from a Future

=head1 SYNOPSIS

use IO::Async::Loop::Mojo;
use Role::Tiny ();

my $loop = IO::Async::Loop::Mojo->new;
my $future = $loop->timeout_future(after => 5);
Role::Tiny->apply_roles_to_object($future, 'Future::Role::Promisify');
$future->promisify->then(sub { say 'Resolved' }, sub { say 'Rejected' })->wait;

use Future::Mojo;
use Mojo::IOLoop;

my $loop = Mojo::IOLoop->new;
my $future = Future::Mojo->new($loop);
$loop->timer(1 => sub { $future->done('Success!') });
$future->promisify->then(sub { say @_ })->wait;

=head1 DESCRIPTION

L<Future::Role::Promisify> provides an interface to chain L<Mojo::Promise>
objects from L<Future> objects.

=head1 METHODS

L<Future::Role::Promisify> composes the following methods.

=head2 promisify

  my $promise = $future->promisify;

Returns a L<Mojo::Promise> object that will resolve or reject when the
L<Future> becomes ready.

=head1 CAVEATS

If the Future is not immediately ready, it must be an instance of
L<Future::Mojo>, or otherwise a Future subclass using the L<Mojo::IOLoop>
singleton such as an L<IO::Async::Future> from the L<IO::Async::Loop::Mojo>
loop. In any other circumstances, the resulting promise may not be able to
resolve.

Cancelling the preceding Future chain may lead to unspecified behavior.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Future>, L<Future::Mojo>, L<Mojo::Promise::Role::Futurify>
