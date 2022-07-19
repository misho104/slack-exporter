#!/usr/bin/perl

use strict;
use warnings;

sub error { print $_[0]; exit 1; }
my $dir = $ARGV[0] or error("usage: $0 dir");
error("not dir $dir") unless -d $dir;

my (%channels, %users);
open(my $c, "$dir/channel_list.txt") or error("cl missing");
open(my $u, "$dir/user_list.txt") or error("ul missing");
foreach(<$c>) {
  chop();
  if(/^\[(\w+)\] (.+?): channel created by/){
    $channels{$1} = "C_$2";
  }elsif(/^\[(\w+)\] (.+?): private channel created by/){
    $channels{$1} = "P_$2";
  }elsif(/^\[(\w+)\] direct_message with (.+)/){
    $channels{$1} = "D_$2";
  }else{
    print("UnknownCL $_\n");
  }
}
foreach(<$u>) {
  chop();
  if(/^\[(\w+)\] (\S+)/){
    $users{$1} = "$2";
  }else{
    print("UnknownUL $_\n");
  }
}
close($c);
close($u);

opendir(my $d, $dir) or error("dir missing?");
foreach(readdir($d)){
  next unless /\.txt$/;
  next if /_list\.txt$/;
  if(/^(channel_(\w+).txt)$/){
    my ($file, $key) = ($1, $2);
    my $name = $channels{$key};
    unless ($name) {
      print("unknown channel-file $_");
      next;
    }
    `cp $dir/$file $dir/$name.txt`;
  }elsif(/^(channel-replies_(\w+).txt)$/){
    my ($file, $key) = ($1, $2);
    my $name = $channels{$key};
    unless ($name) {
      print("unknown channel-file $_");
      next;
    }
    `cp $dir/$file $dir/$name-replies.txt`;
  }else{
    print("unknown file $_\n");
  }
}
close($d);

