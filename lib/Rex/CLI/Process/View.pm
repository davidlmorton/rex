package Rex::CLI::Process::View;

use strict;
use warnings;

use Genome;
use Workflow;
use Procera::Persistence::Amber;

class Rex::CLI::Process::View {
    is => [
        'Genome::Command::Viewer',
        'Genome::Command::WorkflowMixin',
    ],
    has => [
        process => {
            is => 'Text',
            shell_args_position => 1,
            doc => 'Process you want to view',
        },
    ],
};

sub help_synopsis {
    return <<EOP;
    Displays basic information about a process.
EOP
}

sub help_detail {
    return <<EOP;
Displays information about a process and its workflow.

    process view <process_id>

EOP
}

sub write_report {
    my ($self, $width, $handle) = @_;

    my $process_info = _get_process_info($self->process);

    $self->_display_process_info($handle, $process_info);

    my $workflow = _workflow_instance($process_info->{workflow_name});
    $self->_display_workflow($handle, $workflow);
    $self->_display_logs($handle, $workflow);

    1;
}

sub _get_process_info {
    my $process = shift;

    my $amber = Procera::Persistence::Amber->new();
    my $process_info = eval {$amber->get_process($process)};
    unless(defined $process_info) {
        die sprintf("Couldn't find process (%s) in Amber (%s)",
            $process, $amber->base_url);
    }
    return $process_info;
}

sub _display_process_info {
    my ($self, $handle, $process_info) = @_;

    my $allocation = Genome::Disk::Allocation->get(
        id => $process_info->{allocation_id},
    );

    my $format_str = <<EOS;
%s
%s%s
%s%s
%s

EOS
    print $handle sprintf($format_str,
        $self->_color_heading('Process'),
        map {$self->_pad_right($_, $self->COLUMN_WIDTH)} (
            $self->_color_pair('Run By', $process_info->{username}),
            $self->_color_pair('Status', $self->_status_color($process_info->{status})),
            $self->_color_pair('Date Started', $process_info->{date_started}),
            $self->_color_pair('Last Updated', $process_info->{date_ended}),
        ),
        $self->_color_pair('MetaData Directory', $allocation->absolute_path),
    );
}

sub _workflow_instance {
    my $name = shift;

    my $force_scalar = Workflow::Operation::Instance->get(
        name => $name,
    );
    return $force_scalar;
}

1;
