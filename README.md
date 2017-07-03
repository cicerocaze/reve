Rêve
====

## About Rêve

Reve is a web application based on Perl Dancer framework. This application is developed to help linguist professionals to create annotations about linguistic corpus data.

## About Installation

The same applies to the deploying of any application based on Perl Dancer framework. The difference is related to the modules the application requires to be deployed. To check some quick example, please, visit http://perldancer.org/quickstart. Bellow, It is explained the needs and steps to deploy Rêve application.

## Installing Rêve

### 1 - Install Perl environment

Equally to Dancer Framework, depending on the operating system, needs to have the Perl environment setted to be deployed. For Windows users, there are some environments used, like: Strawberry Perl (http://strawberryperl.com/), Dwimperl (http://dwimperl.com/) or ActivePerl (https://www.activestate.com/activeperl) .

For Unix (Mac or Linux) users, Perl is a native language. This way, it is not necessary to install Perl compiler or any environment.

### 2 - Install Dancer framework

For both type of Operational Systems, it will be necessary to install the Dancer framework. To do it, use CPAN (Comprehensive Perl Archive Network). CPAN is a great set of modules and even a module mananger application. It is installed with one of the above mentioned environments (Strawberry, Dwinperl or Activeperl). Once the environment is installed, use the commands "cpan install Dancer2" in the terminal, to install Dancer2 framework. See the example:

    ```$ cpan install Dancer2```

The Perl Dancer2 framework will be downloaded and installed, and with it, lots of mandatory modules will be installed too.

### 3 - Deploying Rêve

When Perl Dancer2 installation is finished, download Rêve application at: https://github.com/cicerocaze/reve.git. Throught the terminal, access the folder of the application and use the commands bellow to deploy Rêve, locally:

    ```$ plackup bin/app.pl```

The application has to be deployed with the following message in the terminal:

    ```HTTP::Server::PSGI: Accepting connections at http://0:5000/```

When the application be deployed, open some browser and access it at "localhost:5000" to see the application running.

## Final considerations

In the third step, possibly, it will misses some module. When that happens, it shows a message saying the name of the missed module. This way, just use the commands "cpan install <Name::OfThe::Module>" to install the missed modules. See how to install some of the modules that are commonly missed:

    $ cpan install Dancer2::Plugin::Database
    $ cpan install DBD::SQLite
    $ cpan install Plack::Runner

When the installation of the missed modules is finished, repeat the commands "plackup bin/app.pl" to deploy the application. When the application deploys, go to the browser and access: localhost:5000 to check the application running.

    * The modules are being missed because the Makefile.pl is not being updated automatically, for while.
