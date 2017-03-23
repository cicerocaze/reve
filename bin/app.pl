#!/usr/bin/env perl

use Plack::Builder;
use FindBin;
use lib "$FindBin::Bin/../lib";

use ReVe;
ReVe->to_app;
