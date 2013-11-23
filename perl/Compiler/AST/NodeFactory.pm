package Compiler::AST::NodeFactory;

use strict;
use warnings FATAL => 'all';


use Carp qw(confess);
use File::Spec qw();

use Compiler::Parser;
use Compiler::AST::Node::Process;
use Compiler::AST::Node::Tool;

use constant EXTENSION => '.gms';


$::RD_HINT = 1;

sub new_node {
    my %params = Params::Validate::validate(@_, {
        source_path => 1,
        alias => 0,
        parallel => 0,
        couplers => 0,
    });

    my $definition_path = resolve_path($params{source_path});
    if ($definition_path) {
        my $process = Compiler::Parser::new_process($definition_path, $params{source_path});
        $process->alias($params{alias}) if defined $params{alias};
        $process->parallel($params{parallel}) if defined $params{parallel};
        $process->couplers($params{couplers}) if defined $params{couplers};
        return $process;
    } else {
        return Compiler::AST::Node::Tool->new(%params);
    }
}

sub resolve_path {
    my $name = shift;
    my $relative_path = $name . EXTENSION();

    for my $base_path (search_path()) {
        my $absolute_path = File::Spec->rel2abs(File::Spec->join(
                $base_path, split(/::/, $relative_path)));
        if (-f $absolute_path) {
            return $absolute_path;
        }
    }

    return;
}

sub search_path {
    if ($ENV{GMSPATH}) {
        return split(/:/, $ENV{GMSPATH});
    }
    return 'definitions';
}

1;