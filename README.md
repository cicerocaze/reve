Rêve
====

# About Rêve

Reve is a web application based on Perl Dancer framework. This application is developed to help linguist professionals to create annotations about linguistic corpus data.  

## About Installation

The installation follows the same instructions provided for deploying any Dancer application. The difference is related to the modules the application require to be deployed. To check details, please, visit: (http://perldancer.org/quickstart). Bellow, It is explained the needs and steps to deploy Rêve application.

## Installing Rêve

Equally to Dancer Framework, depending on the operating system, Rêve needs to have the Perl environment setted to be deployed.
For Linux users this is not necessary because Perl is a native Linux Language. For Windows users, there are two most used environments.
They are: Strawberry Perl or Dwimperl (Derivated from Strawberry Perl), including modules as: Perl IDE, Perl Dancer, Moose, Plack and plackup and others.
Check the page http://dwimperl.com/windows.html for more details.

### Quality Supervision

We can measure our quality using the
[CPAN testers platform](http://www.cpantesters.org).

A good way to help the project is to find a failing build log on the
[CPAN testers](http://www.cpantesters.org/distro/D/Dancer2.html).

If you find a failing test report, feel free to report it as a
[GitHub issue](http://github.com/PerlDancer/Dancer2/issues).

### Reporting Bugs

We prefer to have all our bug reports on GitHub, in the
[issues section](http://github.com/PerlDancer/Dancer2/issues).

Please make sure the bug you're reporting does not yet exist. If in doubt
please ask on IRC.

## Environment and Patch Submission

### Set up a development environment

If you want to submit a patch for Dancer2, you need git and very
likely also [_Dist::Zilla_](https://metacpan.org/module/Dist::Zilla).
We also recommend perlbrew (see below) or,
alternatively, [_App::Plenv_](https://github.com/tokuhirom/plenv))
to test and develop Dancer2 on a recent
version of Perl. We also suggest
[_App::cpanminus_](https://metacpan.org/module/App::cpanminus)
to quickly and comfortably install Perl modules.

In the following sections we provide tips for the installation of some
of these tools together with Dancer. Please also see the documentation
that comes with these tools for more info.

#### Perlbrew tips (Optional)

Install perlbrew for example with

    $ cpanm App::perlbrew

Check which Perls are available

    $ perlbrew available

It should list the available Perl versions, like this (incomplete) list:

    perl-5.17.1
    perl-5.16.0
    perl-5.14.2
    perl-5.12.4
    ...

Now run the init command for perlbrew. The init command initializes and controls
processes. The init command is run as the last step of any startup
process.

    $ perlbrew init


Then install a version inside perlbrew. We recommend you
give a name to the installation (`--as` option), as well as compiling
without the tests (`--n` option) to speed it up.

    $ perlbrew install -n perl-5.14.4 --as dancer_development -j 3

Wait a while, and it should be done. Switch to your new Perl with:

    $ perlbrew switch dancer_development

Now you are using the fresh Perl, you can check it with:

    $ which perl

Install cpanm on your brewed version of Perl.

    $ perlbrew install-cpanm


### Install various dependencies (required)

Install Dist::Zilla

    $ cpanm Dist::Zilla

### Get Dancer2 sources

Get the Dancer sources from github (for a more complete git workflow
see below):

Clone your fork to have a local copy using the following command:

     $ git clone git://github.com/perldancer/Dancer2.git

The Dancer2 sources come with a `dist.ini`. That's the configuration
file for _Dist::Zilla_, so that it knows how to build Dancer2. Let's
use dist.ini to install additional `Dist::Zilla` plugins which are
not yet installed on your system (or Perl installation):

     $ dzil authordeps | cpanm -n

That should install a bunch of stuff. Now that _Dist::Zilla_ is up and
running, you should install the dependencies required by Dancer2:

     $ dzil listdeps | cpanm -n

When that is done, you're good to go! You can use `dzil` to build and test
Dancer2:

     $ dzil build
     $ dzil test --no-author


### Patch Submission (Github workflow)

The Dancer2 development team uses GitHub to collaborate.  We greatly
appreciate contributions submitted via GitHub, as it makes tracking
these contributions and applying them much, much easier. This gives
your contribution a much better chance of being integrated into
Dancer2 quickly!

**NOTE:** All active development is performed in the _master_ branch.
Therefore, all your contribution work should be done in a fork of the
_master_ branch.

Here is the workflow for submitting a patch:

1. Fork the repository: http://github.com/PerlDancer/Dancer2 and click "Fork";

2. Clone your fork to have a local copy using the following command:

        $ git clone git://github.com/myname/Dancer2.git

3. As a contributor, you should **always** work on the `master` branch of
   your clone.

        $ git remote add upstream https://github.com/PerlDancer/Dancer2.git
        $ git fetch upstream

   This will create a local branch in your clone named _master_ and
   that will track the official _master_ branch. That way, if you have
   more or less commits than the upstream repo, you'll be immediately
   notified by git.

4. You want to isolate all your commits in a _topic_ branch, this
   will make the reviewing much easier for the core team and will
   allow you to continue working on your clone without worrying about
   different commits mixing together.

   To do that, first create a local branch to build your pull request:

        # you should be in master here
        $ git checkout -b pr/$name

   Now you have created a local branch named _pr/$name_ where _$name_
   is the name you want (it should describe the purpose of the pull
   request you're preparing).

   In that branch, do all the commits you need (the more the better)
   and when done, push the branch to your fork:

        # ... commits ...
        git push origin pr/$name

   You are now ready to send a pull request.

5. Send a _pull request_ via the GitHub interface. Make sure your pull
   request is based on the _pr/$name_ branch you've just pushed, so
   that it incorporates the appropriate commits only.

   It's also a good idea to summarize your work in a report sent to
   the users' mailing list (see below), in order to make sure the team
   is aware of it.

   You could also notify the core team on IRC, on `irc.perl.org`,
   channel `#dancer` or via [web client](http://www.perldancer.org/irc).

6. When the core team reviews your pull request, it will either accept
   (and then merge into _master_) or refuse your request.

   If it's refused, try to understand the reasons explained by the
   team for the denial. Most of the time, communicating with the core
   team is enough to understand what the mistake was. Above all,
   please don't be offended.

   If your pull request is merged into _master_, then all you have to
   do is remove your local and remote _pr/$name_ branch:

        $ git checkout master
        $ git branch -D pr/$name
        $ git push origin :pr/$name

   And then, of course, you need to sync your local devel branch with
   upstream:

        $ git pull upstream master
        $ git push origin master

   You're now ready to start working on a new pull request!
