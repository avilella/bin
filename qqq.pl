#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $self = bless {};

my $debug; my $verbose; my $simulate;
my $cmd; my $ret;
my $grep; my $qdel; my $silent; my $resubmit;
my $department = 'defaultdep';
GetOptions(

           'grep:s'   => \$grep,
           'qdel'     => \$qdel,
           'silent'   => \$silent,
           'resubmit' => \$resubmit,
           'debug'    => \$debug,
           'verbose'  => \$verbose,
           'simulate' => \$simulate,

          );

$cmd = "qstat -r -ext | grep -v QLOGIN |";
open F, "$cmd" or die $!;
my ($job_id,$prior,$ntckts,$name,$user,$project,$state,$cpu,$mem,$io,$tckts,$ovrts,$otckt,$ftckt,$stckt,$share,$queue,$slots,$ja_task_id);
while (<F>) {
  my $line = $_; chomp $_;
  if ($line =~ /$department/) {
    ($job_id,$prior,$ntckts,$name,$user,$project,$department,$state,$cpu,$mem,$io,$tckts,$ovrts,$otckt,$ftckt,$stckt,$share,$queue,$slots,$ja_task_id) = split(" ",$line);
    $self->{$job_id}{prior} =    $prior    ;
    $self->{$job_id}{ntckts} =   $ntckts    ;
    $self->{$job_id}{name} =    $name       ;
    $self->{$job_id}{user} =    $user       ;
    $self->{$job_id}{project} =   $project   ;
    $self->{$job_id}{department} =   $department;
    $self->{$job_id}{state} =    $state    ;
    $self->{$job_id}{cpu} =    $cpu        ;
    $self->{$job_id}{mem} =    $mem         ;
    $self->{$job_id}{io} =    $io           ;
    $self->{$job_id}{tckts} =    $tckts    ;
    $self->{$job_id}{ovrts} =    $ovrts    ;
    $self->{$job_id}{otckt} =    $otckt    ;
    $self->{$job_id}{ftckt} =    $ftckt    ;
    $self->{$job_id}{stckt} =    $stckt    ;
    $self->{$job_id}{share} =    $share    ;
    $self->{$job_id}{queue} =    $queue    ;
    $self->{$job_id}{slots} =    $slots    ;
    $self->{$job_id}{ja_task_id} =   $ja_task_id;
    next;
  } elsif (defined $job_id && $line =~ /Full jobname\:\s+(\S+)/) {
    my $full_jobname = $1;
    $self->{$job_id}{full_jobname} = $full_jobname;
    $cmd = "perl ~/bin/qtmp.pl -silent -i $full_jobname";
    $ret = `$cmd`; chomp $ret;
    $self->{$job_id}{job_cmd} = $ret;
  }
}

my $home = $ENV{HOME};
if (defined $resubmit) {
  open RESUB, ">$home/resubmit.sh" or die $!;
}

foreach my $job_id (sort keys %$self) {
  my $full_jobname = $self->{$job_id}{full_jobname};
  my $job_cmd          = $self->{$job_id}{job_cmd};
  my $mem          = $self->{$job_id}{mem};
  my $cpu          = $self->{$job_id}{cpu};
  my $queue        = $self->{$job_id}{queue};
  my $slots        = $self->{$job_id}{slots};
  next if (defined $grep && $job_cmd !~ /$grep/);
  print "# $job_id\t$full_jobname\t$mem\t$cpu\t$slots\t$queue\n" unless ($silent);
  print "$job_cmd\n";
  if (defined $qdel) {
    $cmd = "qdel $job_id";
    $ret = `$cmd`; chomp $ret;
  }
  if (defined $resubmit) {
    my $slots          = $self->{$job_id}{slots}; $slots = '' if (1 == $slots);
    my $full_jobname   = $self->{$job_id}{full_jobname};
    my $mem = 2; $full_jobname =~ /\_mem(\d+)G/; $mem = $1 if (defined $1);
    my $this_qsub = "qsubIt" . $slots . " " . $mem . "G";
    my $job_cmd        = $self->{$job_id}{job_cmd};
    my $new_qsub = "$this_qsub \"$job_cmd\"";
    print "## $new_qsub\n";
    print RESUB "$new_qsub\n";
  }
}

if (defined $resubmit) {
  close RESUB;
}

# qqq.pl
#
# Cared for by Albert Vilella <avilella>
#
# Copyright Albert Vilella
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

qqq.pl - DESCRIPTION 

           'grep:s'   => \$grep,
           'qdel'     => \$qdel,
           'silent'   => \$silent,
           'resubmit' => \$resubmit,
           'debug'    => \$debug,
           'verbose'  => \$verbose,
           'simulate' => \$simulate,

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

Describe the object here

=head1 AUTHOR - Albert Vilella

Email avilella

Describe contact details here

=head1 CONTRIBUTORS

Additional contributors names and emails here

=cut


$DB::single=1;1;
$DB::single=1;1;

