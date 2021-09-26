use strict;
use Data::Dumper;


###my @array = ( '10.251.43.167', '10.251.3.76', '10.251.43.199', '10.251.43.198', '10.251.3.76');

###
my @files = ("omi_checker.sh",
            );
# Array to catch all failures:
my @failures = ();
my @failed_logins = ();
###



my @data =();
# build Array
while (<DATA>){
      chomp;
      my $line = $_;
      #1: 7: EAG-DEV01, STG-WRK00, WindowsServer, 10.251.7.6, -Failed ping test, 0 received, 100% packet
      #my($ct,$ct_org_list,$sub,$name,$os,$ip,$failed_msg,$rec,$ploss) = split(/\,\s\s*|\:\s\s*/,$line);
      ###my($name,$os,$ip,$failed_msg,$rec,$ploss) = split(/\,\s\s*|\:\s\s*/,$line);
      #_ssh_mk_dir($dir,$user,$pass,$host)
      my($user,$pass,$ip,$os) = split(/,/,$line);


      #my $item = $sub."_".$name."_".$os."_".$ip;
      my $item = $user."_".$pass."_".$ip."_".$os;

   #   print "^$item^\n"; 
      push @data, $item;
};

print Dumper \@data;
#exit;

my @array = @data;
my $cmd;

print "--- start ---\n";
#my($failed_messages,$success_messages) = _check_vm_with_telnet_(@array);
#my $title;
#$title="Failed -May not exist.";
#print_aref($failed_messages,$title);
#$title="Success - Connection made.";
#print_aref($success_messages,$title);
#print "--- end ---\n";
#exit;

###
my @array = ('infradmin,"V22osprey!!!",10.251.7.132,, -PASSED',
             'infradmin,"Eag-dev02-truck-pear-tiger!",10.251.7.133,, -PASSED', 
             'infradmin,"Eag-dev02-truck-pear-tiger!",10.251.2.4,Centos, -PASSED'
            );
###my @array = ( '', '');
my $success_messages = \@array;
###
my $title = "Process ^omi_check^ script.";
my $dir = "omi_check";
my $log = "fRiday_omi_check.log";
my $cmd = "omi_checker.sh";
process_aref($success_messages,$title,$log,$dir,$cmd,@files);
###

#print "-"x50;
#print "\n";
#foreach my $ii ( 0 .. $#{ $failed_messages } ){
#     my $ct = $ii + 1;
#     print "$ct: ${$failed_messages}[$ii]\n";
#}
print "\n";
print "==Dump \@failures==\n";
print "Dumper \@failures";
print "\n";
my $failures = \@failures;
print_aref($failures,"Failures");
print "\n";
my $failed_logins = \@failed_logins;
print_aref($failed_logins,"Failed Logins");
print "\n";
print "--- end ---\n";
exit;

# SUBS
sub process_aref {
# print aref
print "--Start process_aref--\n";
my($aref,$title,$log,$dir,$cmd,@files) = @_;
## process_aref($success_messages,$title,$log,$dir,$cmd,@files);
print "-"x50;
print "\n---< $title >---\n";
print "\n";
foreach my $ii ( 0 .. $#{ $aref } ){
     my $ct = $ii + 1;
     my $line = ${$aref}[$ii];
     my($user,$pass,$ip,$os) = split(/,|___/,$line);
     $ip =~ s/_//;
     print "$user|$pass|$ip|$os\n";
     ###
     #my($user,$pass,$ip,$os) = split(/,/,$line);
     $pass =~ s/\"//g;
     print "===============< $ip >======================\n";
     print "CONNECT: $user, $pass,$ip,$os\n\n";
     print "TRYING to Connect: $ip\n";
     print "Running: _ssh_mk_dir\n";
     _ssh_mk_dir($log,"mkdir",$dir,$user,$pass,$ip,$os);
     sleep 2;
     print "Running: _ssh_scp\n";
     _ssh_scp($log,$cmd,$dir,$user,$pass,$ip,$os,@files);
     sleep 2;
     print "Running: _ssh_cmd\n";
     _ssh_cmd($log,$cmd,$dir,$user,$pass,$ip,$os);
     ###
     #print "$ct: ${$aref}[$ii]\n";
 }
  print "--Finish process_aref--\n";
};


sub print_aref {
# print aref
my($aref,$title) = @_;
print "-"x50;
print "\n---< $title >---\n";
print "\n";
foreach my $ii ( 0 .. $#{ $aref } ){
     my $ct = $ii + 1;
     print "$ct: ${$aref}[$ii]\n";
 }
};


print "\n";

sub _check_vm_with_telnet_{
my(@array) = @_;
my $port = "22";
my @failed_messages;
my @success_messages;
my $pass; 

foreach my $ii ( 0 .. $#array ){
 print "== processing $array[$ii]\n";
 #my($sub,$names,$ip) = split(/_/,$array[$ii]);
 my $line = $array[$ii];
 chomp($line);
 print "$line\n";
 $line =~ s/_/,/g;
 my($user,$pass,$ip,$os) = split(/,/,$line);
 $ip =~ s/_//g;
 my $vm_string = join(",",$user,$ip);
 $pass = 0;
 my $telnet = "telnet ".$ip." ".$port;
 $cmd = $telnet;
 print "== $telnet \n";
#exit;
  my @output;
  my $pipe = ();
  my $data;
  eval {
    local $SIG{ALRM} = sub { die "Timeout\n" };
    alarm 5;
    open( $pipe, "$telnet |" ) or die "Flaming death on open of pipe ^$cmd^: $!\n";
    while(<$pipe>){ 
            chomp; 
            print "\$_: $_\n"; 
            $data .= $_; 
               if ( $_ =~ m/(connected)/ig ){ 
                       print "-Connected -Pass!\t\t\t\t -Pass!\n"; $pass = 1;
                       ###my($user,$pass,$host,$os) = split(/,/,$line);
                       $pass =~ s/\"//g;
                       push @success_messages, "$line, -PASSED";
                    }  
                     elsif ( $pass eq 0 && $_ !~ m/(trying)/ig ) { 
                               print "^$_^\n"; print "$array[$ii] -FAILED!\n"; 
                               push @failed_messages, "$array[$ii] -FAILED"; 
                       } else {
                         print "^$_^\n";
                     };
                  };
    alarm 0;
};
if ( $pass eq 0 ){ print "^$_^\n"; print "$vm_string -FAILED!\n"; push @failed_messages, "$array[$ii] -FAILED"; };

if ($@) {
    warn "$cmd timed out.\n";
    my $pid = `ps | grep telnet`;
    print "$pid\n";
    my @pid = split(/\s\s*|\t\t*/,$pid);
    my $cmd = "kill -9 $pid[0]";
    print "$cmd\n";
    `$cmd`;
    #print "$data\n";
   } else {
    #print "$cmd successful. Output was:\n", @output;
    print "##$cmd successful. Output was:\n", $data;
  }
};
## totals?
return(\@failed_messages,\@success_messages);
};

###
sub _ssh_scp {
use Net::SCP::Expect;
my($log,$cmd,$dir,$user,$pass,$host,$os,@files) = @_;
#_ssh_scp($log,$cmd,$dir,$user,$pass,$ip,$os,@files);
my $scpe = Net::SCP::Expect->new( timeout => 10 ) ;
$scpe->login($user, $pass);
  foreach my $file ( @files ){
    print "\tSending file: $file\n";
       $scpe->scp($file,$host.":~/$dir");
         };
           my $numfiles = $#files + 1;
             print "Sent [$numfiles] files.\n";
};

###
sub _ssh_mk_dir {
use Net::SSH::Expect;
  my($log,$cmd,$dir,$user,$pass,$host,$os) = @_;
#_ssh_mk_dir($log,$cmd,$dir,$user,$pass,$ip,$os);
#_ssh_mk_dir($log,"mkdir",$dir,$user,$pass,$ip,$os);
  my $ssh = Net::SSH::Expect->new(
    host => $host,
    password=> $pass,
    user => $user,
    raw_pty => 1,
    timeout => 10
);
my $login_output = $ssh->login();
print "\$login_output:\n^$login_output^\n\n";
if($login_output =~ m/Permission denied/i){ print "$host,Password BAD, Bailing -NEXT!\n"; push @failed_logins, "$host,$user,$pass,$os,Password BAD,Bailing -NEXT!"; next; };
print "---< Command Output >---\n";
  $ssh->exec("stty raw -echo");

print "\n";
my $mkdir =  $ssh->exec("$cmd $dir");
my $cd =  $ssh->exec("cd $dir");
print "\t$mkdir\n";
print "\t$cd\n";
my $pwd = $ssh->exec("pwd");
print "\t\$pwd:\n\t$pwd\n\n";
print "---<end>---\n";
$ssh->close();
};

###
sub _ssh_cmd {
 my($log,$cmd,$dir,$user,$pass,$host,$os) = @_;
# _ssh_cmd($log,$cmd,$dir,$user,$pass,$ip,$os);
 print "$log,$cmd,$dir,$user,$pass,$host,$os\n";
my $ssh = Net::SSH::Expect->new (
    host => $host,
    password=> $pass,
    user => $user,
    timeout => 10,
    raw_pty => 1
);
my $login_output = $ssh->login();
print "\t==\$login_output:\n^$login_output^\n\n";

print "---< Command Output >---\n";
print "\n";

my $cd =  $ssh->exec("cd $dir");
print "\t==\$cd: ^$cd^\n";
my $pwd = $ssh->exec("pwd");
print "\t==\$pwd:\n\t^$pwd^\n\n";
my $ls = $ssh->exec("ls -lt");
print "\t++\$ls:\n\t^$ls^\n\n";
my $sudo = $ssh->exec("sudo su");
print "\t==\$sudo: ^$sudo^\n\n";
$ssh->send($pass);
my $whoami = $ssh->exec("whoami");
print "\t==\$whoami: ^$whoami^\n\n";
my $fal_perm = $ssh->exec("chmod u+x $cmd");
my $fal_ls = $ssh->exec("ls -alt $cmd");
print "\t==\$fal_perm: ^$fal_perm, $!^\n\t==\$fal_ls: ^$fal_ls^\n\n";
###
my $os_check = "cat /etc/os-release | grep -E '(NAME\=\"Ubuntu\")'";
my $fal_chk_os = $ssh->exec("$os_check");
print "\t==\$fal_chk_os: ^$fal_chk_os, $!^\n\t==\n";
my $result;
if ( $fal_chk_os =~ m/Ubuntu/ig ){
      print "====OS = Ubuntu\n";
      print "====Running /bin/bash $cmd\n";
      $result = $ssh->send("/bin/bash $cmd");
      } else {
        print "====OS appears to NOT be Ubuntu.\n";
        print "====Running /usr/bin/bash $cmd\n";
        $result = $ssh->send("/usr/bin/bash $cmd");
     };
###
#$ssh->send("/usr/bin/sh $cmd");
print "## ====\$result = ^$result^ ## \n";
$ssh->waitfor('###EC##', 20, -ex) || print " ^Running $cmd.^ not found after 20 second";
my $line;
my $resp;
while ( defined ($line = $ssh->read_line()) ) {
    print "\t====\$line: ^$line^\n";
    #if( $line =~ m/(==Done*)/ig ) {
    # print "==Found ^==Done*^: ^$1^\n";
    # print "==Looks like success!\n";
    if( $line =~ m/(###EC##Y#*)/ig ) {
     print "====Found ^###EC##^: ^$1^\n";
     print "====Looks like success!\n";
     $resp = $1;
     print "====\$resp: $resp\n";
     chomp($resp);
     ###
     } else {
     $resp = $1;
     print "## LINE====Looks like Failure! \n";
     print "## LINE====push to \@failures, $host.",".$resp\n";
     print "## NO PUSH\n";
     ###push @failures, $host.",".$resp; 
     ###
     };
 };   
     
#my $log = $log;
print "\$log: $log\n";
my $cat = $ssh->exec("cat $log");
print "\n######<LOG SNIP>######\n$cat\n######<LOG SNIP>######\n\n";
# ###EC##N#
if( $cat =~ m/(###EC##Y#*)/ig ) {
     print "====Found ^###EC##^: ^$1^\n";
     print "====Looks like success!\n";
     $resp = $1;
     print "====\$resp: $resp\n";
     chomp($resp);
     } else {
     $resp = $1;
     print "## CAT====Looks like Failure! \n";
     print "## CAT====push to \@failures, $host.",$user,$pass,$os,".$resp\n";
     push @failures, $host.",$user,$pass,$os,".$resp;
     };
print "---< finished $cmd >---\n";
$ssh->close();
};


###


#__DATA__
#3: 11: VDOL, vdol01-vm, Oracle-Linux, 10.251.44.37, -Failed ping test, 0 received, 100% packet
#3: 11: VDOL, test-vm, Oracle-Linux, 10.251.16.4, -Failed ping test, 0 received, 100% packet
#15: 76: EAG-BUILD-TEST, eag-mxnet-vm, ubuntu-16-04-minimal-lts-cm, 10.251.51.4, -Failed ping test, 0 received, 100% packet
#36: 118: AOT-CVO-Cloud, EAG-LIN-STG1, CentOS, 10.251.0.77, -Failed ping test, 0 received, 100% packet
__DATA__
phaigh,"V22osprey!!!",10.251.16.21
infradmin,"V22osprey!!!",10.251.7.132,Ubuntu
infradmin,"Eag-dev02-truck-pear-tiger!",10.251.7.133,Ubuntu
infradmin,"Eag-dev02-truck-pear-tiger!",10.251.7.5
infradmin,"Eag-dev02-truck-pear-tiger!",10.251.7.4,Centos,
infradmin,"Eag-dev02-truck-pear-tiger!",10.251.8.4,Centos,
infradmin,"Eag-dev02-truck-pear-tiger!",10.251.8.5,Centos,
infradmin,"Eag-dev02-truck-pear-tiger!",10.251.2.4,Centos,
infradmin,"V22osprey!!!",10.251.149.53,Centos,
infradmin,"V22osprey!!!",10.251.8.4,Centos,
infradmin,"V22osprey!!!",10.251.8.5,Centos,
infradmin,"V22osprey!!!",10.251.147.5,Centos,
infradmin,"V22osprey!!!",10.251.4.6,Centos,
infradmin,"V22osprey!!!",10.251.163.36,Centos,
infradmin,"V22osprey!!!",10.251.147.5,Centos,
infradmin,"V22osprey!!!",10.251.44.36,Centos,
infradmin,"V22osprey!!!",10.251.44.37,Centos,
infradmin,"V22osprey!!!",10.251.131.68,Centos,
infradmin,"V22osprey!!!",10.251.162.4,Centos,
infradmin,"V22osprey!!!",10.251.52.4,Centos,
infradmin,"V22osprey!!!",10.251.21.232,Centos,
phaigh,"v22osprey",10.216.13.98,Centos
infradmin,"v22osprey!!!",10.251.53.36,Centos
infradmin,"v22osprey!!!",10.251.53.37,Centos
infradmin,"V22osprey!!!",10.251.10.68,Centos
infradmin,"V22osprey!!!",10.251.57.4,Centos
