#!/usr/bin/env tclsh

if 0 { ;#### NOTES ####
Using Digital Signatures to Sign a Tcl Script

Two prerequisites must be met to sign a Tcl script:

A digital certificate must be made available on the router that will perform 
the signature check of the Tcl script. The digital certificate is stored in 
the IOS running-configuration and may also be saved in the nonvolatile random-
access memory (NVRAM) of the router.

The Tcl script must have been signed with the private key that matches the 
public key available in the digital certificate. The signature is provided in 
a special format and is in plain text directly after the Tcl commands in the 
script.

If Tcl script signature checking is enabled, different actions can take place 
when a Tcl script is executed. If the signature of the Tcl script matches the 
digital certificate, the Tcl script will be executed immediately. If the 
signature fails to be verified, the following choices are available, 
depending on the IOS configuration:

  The script can be immediately stopped.

  The script can be allowed to run even though the signature check failed, in
  a special "safe" Tcl mode. The "safe" TCL mode has a reduced number of key-
  words available and is thought to be less dangerous than the full Tcl mode.

  The script can be allowed to run normally. This can be used for testing 
  purposes, but would rarely be used in an actual live network. In effect, 
  this turns off the security check.

  To digitally sign a script, an IOS image containing the crypto feature set 
  must be used. This means the image name contains the k9 feature set. For 
  example, the following image contains the crypto feature: 

  ==> c7200-adventerprisek9-mz <==

  The following example details how to correctly sign a Tcl script with a 
  digital signature, using a UNIX host as the certificate authority (CA) 
  server. As an alternative, a CA can also be created using other operating 
  systems or can be hosted commercially.

  A CA is a trusted third party that maintains, verifies, enrolls, 
  distributes, and revokes public keys. It is for that very reason that the 
  CA must be secure.

  The previous examples assumed that Bob or Alice had the other's public 
  key. But how does Bob know that the key he has is really from Alice? There 
  are a couple of answers to that question:

    Alice and Bob exchanged public keys out-of-band. This works fine in a 
    small environment, but when there are hundreds or thousands of devices,
    manually exchanging keys becomes difficult.

    A CA is used to maintain all certificates.

    This is where a CA really shows its value. The CA maintains the public 
    keys or certificates, usually in an X.509 format. Key exchange is as 
    follows:

    Step 1. Before Bob can verify Alice's public key, he must have the CA 
            public key, which should be exchanged out-of-band.
    Step 2. When Bob needs Alice's public key, he sends a request to the CA.
    Step 3. The CA signs Alice's public key with the CA private key, 
            consequently verifying the origination and sends it to Bob.
    Step 4. Bob uses the CA public key to validate Alice's public key.

    You must complete the following steps to sign a Tcl script

    Step 1. Decide on the final Tcl script contents (myscript).
    Step 2. Generate a public/private key pair.
    Step 3. Generate a certificate with the public key.
    Step 4. Generate a detached S/MIME pkcs7 signature for the script you 
            created (myscript) using the private key.
    Step 5. Modify the format of the signature to match the Cisco style for 
            a signed Tcl script and append it to the end of the script you 
            created (myscript).

NOTE

The name of the script will be referred to as myscript throughout this example.
Step 1: Decide on the Final Tcl Script Contents (Myscript)

Finalize any last-minute changes needed to the script text file. After the Tcl script has been signed, no more changes may be made.
Step 2: Generate a Public/Private Key Pair

The private key must always be kept private! Failure to do so would allow anyone in possession of the private key to sign Tcl scripts as if they were written by the original author.

To generate a key pair, you can use the open source project OpenSSL. Executable versions of the OpenSSL are available for download at http://www.openssl.org

NOTE

The versions of utilities mentioned in this chapter were run on Windows XP in the Cygwin environment. Cygwin is a UNIX-like environment for Windows.

$ uname -a
CYGWIN_NT-5.1 joe-wxp01 1.5.25(0.156/4/2) 2008-06-12 19:34 i686 Cygwin
$ openssl version
OpenSSL 0.9.8k 25 Mar 2009
$ expect -version
expect version 5.26
$ xxd -version
xxd V1.10 27oct98 by Juergen Weigert

Using a UNIX host or similar, run the following command to generate a key pair (this example uses a 2048-byte key):

$ openssl genrsa -out privkey.pem 2048
Generating RSA private key, 2048 bit long modulus
..........................................+++
...............................................................................+
++
e is 65537 (0x10001)
$

As you can see from the directory, the following file has been created:

$ ls -l
total 5
-rw-r--r-- 1 joe mkgroup-l-d  114 May 28 10:23 myscript
-rw-r--r-- 1 joe mkgroup-l-d 1679 May 28 10:23 privkey.pem
$

The new file is called privkey.pem and contains both the private key and public key. The file needs to be kept in a secure location because it holds the private key.

Next, extract the public key from the key pair file:

$ openssl rsa -in privkey.pem -pubout -out pubkey.pem
writing RSA key
$

As you can see from the directory, the following file has been created:

$ ls -l
total 6
-rw-r--r-- 1 joe mkgroup-l-d  114 May 28 10:23 myscript
-rw-r--r-- 1 joe mkgroup-l-d 1679 May 28 10:23 privkey.pem
-rw-r--r-- 1 joe mkgroup-l-d  451 May 28 10:25 pubkey.pem
$

Now there are two separate files, one that contains the pair of keys (privkey.pem) and another file that contains only the public key (pubkey.pem).
Step 3: Generate a Certificate with the Key Pair

To create a certificate, we must answer a few questions. These answers will be stored along with the certificate, in case any concerns arise later about where the certificate comes from:

$ openssl req -new -x509 -key privkey.pem -out cert.pem -days 1095

You are about to be asked to enter information that will be incorporated into your certificate request. What you are about to enter is what is called a distinguished name (DN). There are quite a few fields, but some may be left blank.

For some fields there will be a default value. If you enter a period (.), the field will be left blank:

Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:California
Locality Name (eg, city) []:San Jose
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Acme Inc.
Organizational Unit Name (eg, section) []:Central Unit
Common Name (eg, YOUR name) []:Joe
Email Address []:joe@xyz.net

As you can see from the directory, the following cert.pem file has been added:

$ ls -l
total 10
-rw-r--r-- 1 joe mkgroup-l-d 1639 May 28 10:26 cert.pem
-rw-r--r-- 1 joe mkgroup-l-d  114 May 28 10:23 myscript
-rw-r--r-- 1 joe mkgroup-l-d 1679 May 28 10:23 privkey.pem
-rw-r--r-- 1 joe mkgroup-l-d  451 May 28 10:25 pubkey.pem
$

The certificate has now been generated in the file cert.pem. This certificate will later be transferred to the IOS router for the router to perform the signature check on the signed Tcl script.
Step 4: Generate a Detached S/MIME pkcs7 Signature for Myscript Using the Private Key

When the script is signed, a new file is generated called myscript.pk7, which contains the signature:

$ cat myscript
puts hello
puts "argc = $argc"
puts "argv = $argv"
puts "argv0 = $argv0"
puts "tcl_interactive = $tcl_interactive"
$
$ openssl smime -sign -in myscript -out myscript.pk7 -signer cert.pem -inkey pr
ivkey.pem -outform DER –binary
$

The myscript.pk7 file has been added:

$ ls -l myscript.pk7
-rw-r--r-- 1 joe mkgroup-l-d 1856 May 28 10:30 myscript.pk7
$

To validate that the signature matches the myscript certificate we generated earlier, perform the following:

$ openssl smime -verify -in myscript.pk7 -CAfile cert.pem -inform DER -content
myscript
puts hello
puts "argc = $argc"
puts "argv = $argv"
puts "argv0 = $argv0"
Verification successful
puts "tcl_interactive = $tcl_interactive"
$

The "Verification successful" message indicates that myscript matches the contents of the signature.
Step 5: Modify the Format of the Signature to Match the Cisco Style for Signed Tcl Scripts and Append It to the End of Myscript

Now that a signature for myscript has been generated, we still need to make some formatting changes to put myscript in the correct format for Cisco IOS to understand.

The format of a signed Tcl script is as follows:

Actual Tcl script contents in plain test
...
#Cisco Tcl Signature V1.0
#Actual hex data of the signature

The signature portion of myscript is inserted after the hash character (#). Tcl always treats this as a comment. If this script is executed on an IOS router that does not know about Tcl script signature checking, the router will simply ignore these commented lines.

The signature must be converted to a hex format instead of binary:

$ xxd -ps myscript.pk7 > myscript.hex
$

The directory listing shows that the file was created:

$ ls -l myscript.hex
-rw-r--r-- 1 joe mkgroup-l-d 3774 May 28 10:42 myscript.hex
$

Next, a helper script is used to place the #Cisco Tcl Signature V1.0 and the # characters in the new signature file.

You can show the contents of the file by using the cat command:

$ cat my_append
#!/usr/bin/expect
set my_first {#Cisco Tcl Signature V1.0}
set newline {}
set my_file [lindex $argv 0]
set my_new_file ${my_file}_sig
set my_new_handle [open $my_new_file w]
set my_handle [open $my_file r]
puts $my_new_handle $newline
puts $my_new_handle $my_first
foreach line [split [read $my_handle] "\n"]  {
   set new_line {#}
   append new_line $line
   puts $my_new_handle $new_line
}
close $my_new_handle
close $my_handle
$

Initiate the helper script using the following syntax:

$ ./my_append myscript.hex
$

The directory listing shows the myscript.hex and myscript.hex_sig files:

$ ls -l myscript.hex*
-rw-r--r-- 1 joe mkgroup-l-d 3774 May 28 10:42 myscript.hex
-rw-r--r-- 1 joe mkgroup-l-d 3865 May 28 10:56 myscript.hex_sig
$

Lastly, the signature file and the script file must be concatenated:

$ cat myscript myscript.hex_sig > myscript.tcl
$

The directory listing shows that the file was created:

$ ls -l myscript.tcl
-rw-r--r-- 1 joe mkgroup-l-d 3979 May 28 10:58 myscript.tcl
$

puts {The signed Tcl script has finally been generated (myscript.tcl)!}
puts {The following script combines many of the preceding steps and will help to automate the process:}

}
# configure routers
PE11(config)#crypto pki trustpoint TCLSecurity
PE11(ca-trustpoint)#enrollment terminal
PE11(ca-trustpoint)#crypto pki authenticate TCLSecurity

}

#!/bin/sh
# REAL SCRIPT

proc PrintUsageInfo {} {
         puts {usage:  signme input_file [-c cert_file] [ -k privkey_file]} }

set cert_file cert.pem
set privkey_file privkey.pem

if {$argc == 0} {
    PrintUsageInfo
    exit -1
}

set state flag
set cnt 0
foreach arg $argv {
    switch -- $state {
        flag {
            switch -glob -- $arg {
               \-c {
                   set state cert
               }
               \-k {
                   set state key
               }
               default {
                   if {$cnt == 0} {
                       set filename $arg
                   } else {
                       PrintUsageInfo
                       exit -1
                   }
               }
           }
       }
       cert {
           set cert_file $arg
           set state flag
       }
       key {
           set privkey_file $arg
           set state flag
       }
   }
   incr cnt
}

if {![string equal $state flag]} {
    PrintUsageInfo
    exit -1
}

if {[catch {set commented_signed_hex [exec openssl smime -sign -in $filename     -signer $cert_file -inkey $privkey_file -outform DER -binary | xxd -ps     | sed s/^/#/ ]} err]} {
    puts stderr "Error signing $filename - $err"
    exit -1
}

set signature_tag "\n#Cisco Tcl Signature V1.0"

if {[catch {set fd [open $filename a+]} err]} {
    puts stderr "Cannot open $filename  - $err"
    exit -1
}

puts $fd $signature_tag
puts $fd $commented_signed_hex
close $fd

puts "$filename signed successfully."
exit
