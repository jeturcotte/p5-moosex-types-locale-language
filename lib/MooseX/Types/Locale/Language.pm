package MooseX::Types::Locale::Language;


# ****************************************************************
# general dependence(-ies)
# ****************************************************************

use 5.008_001;
use Locale::Language;
use MooseX::Types::Moose qw(
    Str
);
use MooseX::Types (
    -declare => [qw(
        LanguageName
        LanguageCode
    )],
);


# ****************************************************************
# namespace clearer
# ****************************************************************

use namespace::clean;


# ****************************************************************
# public class variable(s)
# ****************************************************************

our $VERSION = "0.000";


# ****************************************************************
# private class variable(s)
# ****************************************************************

# Because language2code($_) cannot coerce 'japanese' to 'Japanese'.
my %language2code;
@language2code{ all_language_names() } = ();

# Because code2language($_) cannot coerce 'JA' to 'ja'.
my %code2language;
@code2language{ all_language_codes() } = ();


# ****************************************************************
# subtype(s) and coercion(s)
# ****************************************************************

# ----------------------------------------------------------------
# language code as defined in ISO 639-1
# ----------------------------------------------------------------
subtype LanguageCode,
    as Str,
        where {
            exists $code2language{$_};
        },
        message {
            "Validation failed for code failed with value ($_) because: " .
            "Specified language code does not exist in ISO 639-1";
        };

coerce LanguageCode,
    from Str,
        via {
            # Converts 'EN' into 'en'.
            return lc $_;
        };

# ----------------------------------------------------------------
# language name as defined in ISO 639-1
# ----------------------------------------------------------------
subtype LanguageName,
    as Str,
        where {
            exists $language2code{$_};
        },
        message {
            "Validation failed for name failed with value ($_) because: " .
            "Specified language name does not exist in ISO 639-1";
        };

coerce LanguageName,
    from Str,
        via {
            # - Converts 'eNgLiSh' into 'English'.
            # - Cannot use 'ucfirst lc', because there is 'Rhaeto-Romance'.
            # - In case of invalid name, returns original $_
            #   to use it in exception message.
            return code2language( language2code($_) ) || $_;
        };


# ****************************************************************
# return true
# ****************************************************************

1;
__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

MooseX::Types::Locale::Language - Locale::Language related constraints and coercions for Moose

=head1 SYNOPSIS

    {
        package Foo;

        use Moose;
        use MooseX::Types::Locale qw(
            LanguageCode
            LanguageName
        );

        has 'code' => (
            isa         => LanguageCode,
            is          => 'rw',
            coerce      => 1,
        );

        has 'name' => (
            isa         => LanguageName,
            is          => 'rw',
            coerce      => 1,
        );

        __PACKAGE__->meta->make_immutable;
    }

    my $foo = Foo->new(
        code => 'JA',
        name => 'JAPANESE',
    );
    print $foo->code;   # 'ja'
    print $foo->name;   # 'Japanese'


=head1 DESCRIPTION

This module packages several L<Moose::Util::TypeConstraints> with coercions,
designed to work with the values of L<Locale::Language>.

=head1 CONSTRAINTS AND COERCIONS

=over 4

=item C<LanguageCode>

A subtype of C<Str>, which should be defined in ISO 639-1 language code.
If you turned C<coerce> on, C<Str> will be lower-case.
For example, C<'JA'> will convert to C<'ja'>.

=item C<LanguageName>

A subtype of C<Str>, which should be defined in ISO 639-1 language name.
If you turned C<coerce> on, C<Str> will be same case as canonical name.
For example, C<'JAPANESE'> will convert to C<'Japanese'>.

=back

=head1 SEE ALSO

=over 4

=item * L<Locale::Language>

=item * L<MooseX::Types::Locale::Language::Fast>

=item * L<MooseX::Types::Locale::Country>

=back

=head1 VERSION CONTROL

This module is maintained using git.
You can get the latest version from
L<git://github.com/gardejo/p5-moosex-types-locale-language.git>.

=head1 AUTHOR

=over 4

=item MORIYA Masaki ("Gardejo")

C<< <moriya at ermitejo dot com> >>,
L<http://ttt.ermitejo.com/>

=back

=head1 COPYRIGHT

Copyright (c) 2009 by MORIYA Masaki ("Gardejo"),
L<http://ttt.ermitejo.com>.

This library is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
See L<perlgpl> and L<perlartistic>.

=cut