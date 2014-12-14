package Dist::Zilla::Plugin::shcompgen::InitOnInstall;

our $DATE = '2014-12-14'; # DATE
our $VERSION = '0.01'; # VERSION

use 5.010001;
use strict;
use warnings;
use utf8;

use Moose;
use namespace::autoclean;

use List::Util qw(first);

with (
    'Dist::Zilla::Role::InstallTool',
);

sub setup_installer {
  my ($self) = @_;

  # first, try MakeMaker
  my $build_script = first { $_->name eq 'Makefile.PL' }
      @{ $self->zilla->files };
  $self->log_fatal('No Makefile.PL found. Using [MakeMaker] is required')
      unless $build_script;

  my $content = $build_script->content;

  no strict 'refs';
  my $header = "
# modify generated Makefile to run 'shcompgen init' & 'shcompgen generate'\n".
"# during installation. this piece is generated by " . __PACKAGE__ . " version " .
    (${__PACKAGE__ ."::VERSION"} // 'dev').".\n";

  my $body = <<'_';
SHCOMPGEN_INIT:
{
    print "Modifying Makefile to run 'shcompgen init' & 'shcompgen generate'\n";
    open my($fh), "<", "Makefile" or die "Can't open generated Makefile: $!";
    my $content = do { local $/; ~~<$fh> };

    $content =~ s/^(install :: pure_install doc_install)/$1 shcompgen_init/m
        or die "Can't find pattern in Makefile (1)";

    $content .= qq|\nshcompgen_init :\n\t| .
        q|$(PERLRUN) -E'require App::shcompgen; my %args; App::shcompgen::_set_args_defaults(\%args); App::shcompgen::init(%args); App::shcompgen::generate(%args, replace=>1)'| .
        qq|\n\n|;

    open $fh, ">", "Makefile" or die "Can't write modified Makefile: $!";
    print $fh $content;
}
_

  $content .= $header . $body;

  return $build_script->content($content);
}

no Moose;
1;
# ABSTRACT: Run 'shcompgen init' & 'shcompgen generate' when distribution is installed

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::shcompgen::InitOnInstall - Run 'shcompgen init' & 'shcompgen generate' when distribution is installed

=head1 VERSION

This document describes version 0.01 of Dist::Zilla::Plugin::shcompgen::InitOnInstall (from Perl distribution Dist-Zilla-Plugin-shcompgen-InitOnInstall), released on 2014-12-14.

=head1 SYNOPSIS

In your dist.ini:

 [shcompgen::InitOnInstall]

=head1 DESCRIPTION

This plugin is meant only for building L<App::shcompgen>.

=for Pod::Coverage setup_installer

=head1 SEE ALSO

L<shcompgen>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Dist-Zilla-Plugin-shcompgen-InitOnInstall>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Dist-Zilla-Plugin-shcompgen-InitOnInstall>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-shcompgen-InitOnInstall>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut