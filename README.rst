Wacky funcubular configs straight from the bugland!
===================================================

|Please do not resize this app|

Whats even happening here?
--------------------------

So I have around :math:`3\frac{1}{2}` machines and they are as follows:

#. / tjmaxxer: My gaming beast. It hits :math:`T_{\text{Jmax}}` in no
   time.

   - No relation to TJ Maxx stores

   - Uses systemd-repart (brokey) for partitioning

   - Uses systemd-homed (brokey) for users

   - It used to use home-manager standalone but I found a funny
     workaround so it does not anymore

#. / disko-elysium: Very old very bad laptop.

   - Uses disko for partitioning

     - Will not do that anymore disko is kinda mid lol

   - It plays Team Fortress 2 now

#. / msi-colgate: Got this built in a shop

   - Probably got fleeced

   - How will I ever acquire more DDR4 ram

   - It is my workhorse

#. / vps01: This **was** a very cheap VPS I rented for a year because
   paying for Adguard is stupid. It is actually like 4x as costly as
   Adguard.

   - **Ran** a lot of tools like:

     #. Dolibarr

     #. Blocky

     #. Paperless-NG, I almost never use it

     #. Searx-NG, but I dont use it

     #. An entire glue DNS server

     - Not FreshRSS yet, for some reason (I keep delaying it)

   - Also used disko for partitioning

     - And facter for hardware discovery

       - but now everything uses facter because I hate my life

#. / phone-home: This is actually just nix-on-droid, so it doesn’t count
   as a whole device really amirite gamers?

   - Hardest to debug

   - Will probably die next year due to Google being predatory

   - I have literally uninstalled it

There are also a few packages, I will put them here:

#. / bizhub-225i-ppds: Classic printer stuff, only packages for two
   distros so we just extract the binaries and autopatch them.

#. / epson-l3212: So for some reason, Epson didn’t put them on foomatic
   yet. I tried another model that did exist on foomatic, but the print
   quality is bad.

   - Fortunately this one is a ‘src-build” package so nixpkgs can
     actually build it directly. However theres a bit of copying files
     around which I couldn’t figure out myself so I just stole a similar
     foomatic package.

   - / Why didn’t you just override that package?: Seemed like too much
     work, a lot of fields changed

#. / naps2-wrapped: I NEED TIFF, I do not care how old or insecure
   libtiff is, if scantailor needs TIFF, so do I.

There’s also a slightly bizarre devShell that consists solely of stuff I
need to set up helix, and some scripts.

One thing you will notice that every machine seems to be on its own set
of tools. This is deliberate, as I don’t really know how each of them
fare. I am using my daily drivers to compare experimental technologies.

As I gain more experience in the NixOS ecosystem, I will try to unify
them.

Feel free to drop any suggestions. I am kind of new to this nix
ecosystem, so chances are I am most likely in the wrong about most
things.

.. |Please do not resize this app| image:: don't_resize_1920x1080_only.svg
