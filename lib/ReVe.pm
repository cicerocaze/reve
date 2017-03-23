package ReVe;
use Dancer2;
use Dancer2::Plugin::Database;
#use PHP::Include (our => 1);
#use CWB::CQP::More;
use Try::Tiny;

#include_php_vars("/linguateca/www/html/acesso/var_corpora.php");
#line 10
# put this line number in the line above

our $debug = 0;
our $VERSION = '0.1';

post '/new' => sub {
    my $step = defined param("step") ? param("step") : 0;

    my $session = session "status" || {};

    if ($step == 0) {
        session status => {};
        return template 'new1';
    }

    if ($step == 1) {
        my $title = param("title");
        redirect "/" unless defined $title and length($title) > 4;
        $session->{title}  = $title;
        $session->{concs}  = [];
        $session->{desc}   = param("desc")  if defined param("desc");
        $session->{author} = param("autor") if defined param("autor");
        session status => $session;
        return template 'new2' => { %$session,
                                    show_debug => $debug};
    }

    if ($step == 2) {
        redirect "/" unless defined param("query");

        $session->{current} = {
                               results => [ query(param("corpo"), param("query")) ],
                               query => param("query"),
                               corpo => param("corpo"),
                              };

        session status => $session;
        return template 'new3' => { show_debug => $debug, 
                                 %$session};
    }

    if ($step == 3) {
        redirect "/" unless defined param("submit");

        my $action = param("submit");
        my $concs  = param("conc");
        $concs = [$concs] unless ref($concs) eq "ARRAY";

        push @{$session->{concs}}, 
            map { $session->{current}{results}[$_] } @$concs;

        session status => $session;

        if ($action eq "addEnd") {
            return template 'new4' => {  show_debug => $debug };
        } else {
            return template 'new2' => { show_debug => $debug,  %$session};
        }
    }

    if ($step == 4) {
        redirect "/" unless defined param("class");

        delete $session->{current};

        my $class = param("class");
        $class = [$class] unless ref $class eq "ARRAY";
        my $descriptors = param("classD");
        $descriptors = [$descriptors] unless ref $descriptors eq "ARRAY";

        while (@$class) {
            my $c = shift @$class;
            my $d = shift @$descriptors;
            $session->{classes}{$c} = $d;
        }

        _save($session);
        session status => {};

        return forward "/", {}, {method=>'GET'};
    }
};

get '/view/*/*' => sub {
    my ($project_id, $username) = splat;
    my $concs = _get_concs($project_id);

    # XXX -- talvez colocar isto no _get_concs??
    $concs = [
              map {$concs->{$_}} sort { $a <=> $b } keys %$concs
             ];

    my $obs = _get_user_obs($project_id, $username);
    my $revisions = _get_user_revisions($project_id, $username);
    my $classes = _get_classes($project_id);
    my $class_by_id = {};
    for (@$classes) {
        $class_by_id->{$_->{id}} = $_;
    }

    template 'view' =>
      {
       username => $username,
       classes => $class_by_id,
       revs    => $revisions,
       obs     => $obs,
       concs   => $concs,
       project => _get_project($project_id),
      };
};

get '/tsv/*' => sub {
    my ($id) = splat;

    my $users   = _get_users_for_project($id); ## [ username ]
    my $concs   = _get_concs($id);             ## id -> { hash }
    my $revs    = _get_all_revisions($id);



    my $tsv = "id\tconc\t".join("\t",@$users)."\n";

    my $data;

    for my $record (@$revs) {
        my $text = $record->{text};

        $text =~ s/[\n\t]/ /g;
        $text =~ s/\s+/ /g;

        $data->{$record->{conc_id}}{conc} = $text;
        push @{$data->{$record->{conc_id}}{revs}{$record->{username}}}, $record->{name};
    }

    for my $id (sort keys %$data) {
        $tsv .= "$id\t" . $data->{$id}{conc};
        for my $user (@$users) {
            $tsv .= "\t";
            if (exists($data->{$id}{revs}{$user})) {
                $tsv .= join(",", @{$data->{$id}{revs}{$user}});
            } else {
                $tsv .= "---";
            }
        }
        $tsv .= "\n";
    }

    header content_disposition => "inline; filename=$id.tsv";
    content_type "text/tsv";
    return $tsv
};

get '/json/*/*' => sub {
    my ($id, $user) = splat;

    my $obs = _get_user_obs($id, $user);
    my $revisions = _get_user_revisions($id, $user);

    content_type "application/json";
    to_json({ obs => $obs, revs => $revisions });
};


#----------------------------------------------------------------------

get '/stats/*' => sub {
    my ($id) = splat;
    my $users   = _get_users_for_project($id); ## [ username ]
    my $concs   = _get_concs($id);             ## id -> { hash }
    my $revs    = _get_all_revisions($id);

    my $by_conc;
    my $by_author;
    my $classes;
    my $offclasses = _get_classes($id);
    my $detailed;

    for my $record (@$revs) {
        my $text = $record->{text};

        $text =~ s/[\n\t]/ /g;
        $text =~ s/\s+/ /g;

        $by_conc->{$record->{conc_id}}{conc} = $text;

        $by_author->{$record->{username}}{$record->{name}}++;
        $classes->{$record->{name}}++;

        $detailed->{$record->{conc_id}}{$record->{username}}{$record->{name}}++;
    }

    my $detailed_classes;
    my $detailed_count;
    for my $conc (keys %$detailed) {
        for my $author (keys %{$detailed->{$conc}}) {
            my $tag = join("|", sort keys %{$detailed->{$conc}{$author}});
            $detailed->{$conc}{$author} = $tag;
            $detailed_count->{$author}{$tag}++;
            $detailed_classes->{$tag}++;

            push @{$by_conc->{$conc}{revs}{$tag}}, $author;
        }
    }

    template 'stats' => {
                         by_author => $by_author,
                         classes => [map { $_->{name} } @$offclasses],
                         by_conc => $by_conc,
                         detailed => $detailed_count,
                         detailed_classes => [sort keys %$detailed_classes],
                        }

};


#----------------------------------------------------------------------

get '/review/*' => sub {
	my ($id) = splat;

	my $concs = _get_concs($id);
	my $lrevs = _get_latest_revision($id);
	for my $r (keys %$lrevs) {
		$concs->{$r}{class} = $lrevs->{$r};
	}
	my $revs = _get_all_revisions($id);
	for my $r (@$revs) {
		$r->{timestamp} = localtime $r->{timestamp};
		push @{$concs->{$r->{conc_id}}{revs}}, $r;
	}

	$concs = [
		map {$concs->{$_}} sort { $a <=> $b } keys %$concs
	];

	template 'project' => {
		project   => _get_project($id),
		concs     => $concs,
		classes   => _get_classes($id),
	}
};

#------------------------------------------------------------

get '/bootstrap/*' => sub {
	my ($id) = splat;

	my $concs = _get_concs($id);
	$concs = [
		map {$concs->{$_}} sort { $a <=> $b } keys %$concs
	];

	template 'project' => {
		project   => _get_project($id),
		concs     => $concs,
		classes   => _get_classes($id),
		bootstrap => 1,
	}
};


get '/bootstrap/*/*' => sub {
	my ($id, $user) = splat;

	my $concs = _get_concs($id);
	$concs = [
		map {$concs->{$_}} sort { $a <=> $b } keys %$concs
	];

	template 'project' => {
                               from_user => $user,
                               project   => _get_project($id),
                               concs     => $concs,
                               classes   => _get_classes($id),
                               bootstrap => 1,
	}
};

#--------------------------------------------------------------

#Remove projeto da Base de dados
#------------------------------------------------------------

get '/remov/*' => sub {
	my ($id) = splat;

	my $concs = _get_concs($id);
	$concs = [
		map {$concs->{$_}} sort { $a <=> $b } keys %$concs
	];

	template 'project' => {
		project   => _get_project($id),
		concs     => $concs,
		classes   => _get_classes($id),
		bootstrap => 1,
	}
};

#--------------------------------------------------------------

get '/details/*/*' => sub {
	my ($id, $conc_id) = splat;

	my $classes;
	my $revisions = _get_revisions($conc_id);
	for (@{ _get_classes($id) }) {
		$classes->{$_->{id}} = $_;
	}
	$revisions = [ map {
		$_->{timestamp} = localtime($_->{timestamp});
		$_->{class}     = $classes->{$_->{class_id}};
		$_
	} @$revisions ];

	template 'detail' => {
		project   => _get_project($id),
		conc      => _get_conc($conc_id),
		revisions => $revisions,
	};
};

post '/save/*' => sub {
	my ($id) = splat;

	my $username = param('username');

    my %fields  = params();
	my @classes = grep { /^class\d+$/ } keys %fields;

        _clear_annotations_project_user($id, $username);

	for my $class (@classes) {
            my $v = $fields{$class};
            my @values = (ref($v) || "") eq "ARRAY" ? @$v : $v;

            for my $val (@values) {
                $class =~ /class(\d+)/;
	 	my $conc_id = $1;
	 	_save_revision($id, $conc_id, $val, $fields{"obs$conc_id"}, $username);
            }
        }

        redirect '/';
};

get '/' => sub {
    template 'index' => {
    	current => _get_projects()
    }
};



# CREATE TABLE "rev" ("id" INTEGER PRIMARY KEY IA,
#                     "titulo",
#                     "open" BOOL NOT NULL DEFAULT 1,
#                     "user" VARCHAR,
#                     "desc" VARCHAR)
sub _get_projects {
    my @projects = database->quick_select('rev', {});
    for (@projects) {
        $_->{revisors} = _get_users_for_project($_->{id});
    }
    return \@projects;
}

sub _get_project {
	my $id = shift;
	my @x = database->quick_select('rev', { id => $id });
	return $x[0];
}

# CREATE TABLE "conc" ("id" INTEGER PRIMARY KEY AI NOT NULL,
#                      "rev_id" INTEGER NOT NULL ,
#                      "text" varchar);
sub _get_concs {
	my $id = shift;
	+{ map { ($_->{id} => $_)} (database->quick_select('conc', { rev_id => $id })) }
}

sub _get_conc {
	my $id = shift;
	my @x = database->quick_select('conc', { id => $id });
	return $x[0];
}

# CREATE TABLE "classes" ("id" INTEGER PRIMARY KEY AI,
#                         "rev_id" INTEGER NOT NULL,
#                         "order" INTEGER NOT NULL,
#                         "name" VARCHAR NOT NULL,
#                         "desc" VARCHAR)
sub _get_classes {
	my $id = shift;
	[ database->quick_select('classes', { rev_id => $id }, { order_by => 'order' })]
}

sub _clear_annotations_project_user {
    my ($id, $username) = @_;

    my $sth = database->prepare("DELETE FROM revision WHERE username = ? AND conc_id IN (SELECT id FROM conc WHERE rev_id = ?)");
    $sth->execute($username, $id);
}

# CREATE TABLE "revision" ("conc_id" INTEGER NOT NULL,
#                          "class_id" INTEGER NOT NULL,
#                          "username" VARCHAR NOT NULL,
#                          "timestamp" DATETIME NOT NULL,
#                          "obs" VARCHAR,
#                          PRIMARY KEY ("conc_id", "class_id", "username"))

sub _get_all_revisions {
	my ($id) = @_;
	# classes.name, classes.desc, revision.conc_id, revision.class_id, revision.username, revision.obs, revision.timestamp
	my $sth = database->prepare("SELECT * FROM (conc INNER JOIN revision ON conc.id = revision.conc_id) as X INNER JOIN classes ON X.class_id = classes.id WHERE X.rev_id = ?;");
	$sth->execute($id);
	$sth->fetchall_arrayref({});
}

sub _get_latest_revision {
	my ($id) = @_;
	my $dbh = database->prepare("SELECT conc.id, revision.class_id, MAX(timestamp) FROM conc INNER JOIN revision ON conc.id = revision.conc_id WHERE conc.rev_id = ? GROUP BY conc_id;");
	$dbh->execute($id);
	$dbh->fetchall_hashref("id");
}

sub _save_revision {
	my ($id, $conc_id, $classe, $obs, $username) = @_;
	my $dbh = database->prepare(q{
		INSERT OR REPLACE INTO revision VALUES (?,?,?,?,?);
		});
	$dbh->execute($conc_id, $classe, $username, time, $obs);
}

sub _get_user_obs {
    my ($pid, $uname) = @_;
    my $sth = database->prepare(q{
            SELECT revision.conc_id, revision.obs
            FROM revision INNER JOIN conc
            ON revision.conc_id = conc.id
            WHERE conc.rev_id = ? AND revision.username = ?;
    });
    $sth->execute($pid, $uname);
    my $data = $sth->fetchall_arrayref( {} );
    my $res = {};
    for (@$data) {
        $res->{$_->{conc_id}} = $_->{obs};
    }
    return $res;
}

sub _get_user_revisions {
    my ($pid, $uname) = @_;
    my $sth = database->prepare(q{
            SELECT revision.conc_id, revision.class_id
            FROM revision INNER JOIN conc
            ON revision.conc_id = conc.id
            WHERE conc.rev_id = ? AND revision.username = ?;
    });
    $sth->execute($pid, $uname);
    my $data = $sth->fetchall_arrayref( {} );
    my $res = {};
    for (@$data) {
        push @{$res->{$_->{conc_id}}}, $_->{class_id};
    }
    return $res;
}

sub _get_users_for_project {
    my ($id) = @_;
    my $sth = database->prepare(q{
            SELECT DISTINCT(revision.username)
            FROM revision INNER JOIN conc
            ON revision.conc_id = conc.id
            WHERE conc.rev_id = ?;
    });
    $sth->execute($id);
    my $res = $sth->fetchall_arrayref( [] );
    return [ map { $_->[0] } @$res ];
}

sub query {
    my ($corpo, $query) = @_;

    my $cqp = CWB::CQP::More->new( { utf8 => 0 } );
    $cqp->change_corpus(uc $corpo);
    $cqp->set(Context  => [1, 's'],
              LD       => "'<b>'",
              RD       => "'</b>'");

    $query = guess_query($query);

    try {
        $cqp->exec("A = $query;");
        my $result_size = $cqp->size('A');
        $result_size = 1000 if $result_size > 1000;

        # return map { 
        #     $_ =~ s/>/&gt;/g;
        #     $_ =~ s/</&lt;/g;
        #     $_
        # } 
        return $cqp->cat('A', 0, $result_size);

    } catch {
        die "Erro ao procurar: $query\n";
    };
}

sub guess_query {
    my $query = shift;
    if ($query =~ m!^[^"\[]+$!) {
        my @words = split /\s+/, $query;
        $query = join(" ", map { "[word=\"$_\"]" } @words);
    }
    return $query;
}

# CREATE TABLE "rev" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "titulo" , "open" BOOL NOT NULL  DEFAULT 1, "user" VARCHAR, "desc" VARCHAR);
# CREATE TABLE "conc" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "rev_id" INTEGER NOT NULL , "text" varchar);
# CREATE TABLE "classes" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "rev_id" INTEGER NOT NULL , "order" INTEGER NOT NULL , "name" VARCHAR NOT NULL , "desc" VARCHAR);

sub _save {
    my $struct = shift;

    database->quick_insert( rev => { titulo => $struct->{title},
                                     user   => $struct->{author} || "anonymous",
                                     desc   => $struct->{desc} || "---" });
    $struct->{id} = database->last_insert_id(undef, undef, 'rev', 'id');

    for my $c (keys %{$struct->{classes}}) {
        database->quick_insert(classes => { rev_id => $struct->{id},
                                            order  => 1,
                                            name   => $c,
                                            desc   => $struct->{classes}{$c} });
    }

    for my $c (@{$struct->{concs}}) {
        database->quick_insert(conc => { rev_id => $struct->{id}, text => $c });
    }
}

true;
