//Função botão Anotar
function obtain_user_name_to_review (other_user) {
    var username = null;
    username = prompt("Introduza nome do utilizador.");

    if (!username) {
	window.location = $("#uri_base").val();
    }

    $("#username").val(username);

    $.ajax({
        dataType: "json",
        url: uri_base + "/json/" + project_id + "/" + other_user,
        success: function (data) {
            fill_obs(data['obs']);
            fill_revs(data['revs']);
        } 
    });
}



function esconder_revisoes() {
	$(".revisoes").hide();
}

function toggle_revisoes(button) {
	$(".revisoes").toggle();
	if ($(".revisoes").is(":visible")) {
		button.html("Esconder Revisões");
	} else {
		button.html("Mostrar Revisões");
	}
}

function obtain_user_name () {
    var username = null;
    username = prompt("Introduza nome do utilizador.");

    if (!username) {
	window.location = $("#uri_base").val();
    }

    $("#username").val(username);

    $.ajax({
        dataType: "json",
        url: uri_base + "/json/" + project_id + "/" + username,
        success: function (data) {
            fill_obs(data['obs']);
            fill_revs(data['revs']);
        }
    });
}

function fill_revs( revs ) {
    for (var cid in revs) {
        for (var classe in revs[cid]) {
            select_class(cid, revs[cid][classe]);
			console.log(revs);
        }
    }
}

function fill_obs( obs ) {
    for (var cid in obs) {
        $("#obs" + cid).val(obs[cid]);
    }
}

function get_parent_id( e ) {
    var drop = e.parents(".dropdown");
    return drop.attr("id");
}

function select_class(cid, classe) {
    $("#drop" + cid + ' input[value="' + classe + '"]').click();
}


$(
    function () {
        
        $(".dropdown dt").on('click', function () {
            var id = get_parent_id( $(this) );
            $("#" + id + " dd ul").slideToggle('fast').css('z-index', 9999);
        });

        $(".dropdown dd ul li a").on('click', function () {
            var id = get_parent_id( $(this) );
            $("#" + id + " dd ul").hide();
        });

        $(document).bind('click', function (e) {
            var $clicked = $(e.target);
            if (!$clicked.parents().hasClass("dropdown"))
                $(".dropdown dd ul").hide();
        });

        $('.mutliSelect input[type="checkbox"]').on('click', function () {
            var id = get_parent_id( $(this) );
            var title = $(this).closest("#" + id + ' .mutliSelect').
                find('input[type="checkbox"]').val(),
            title = $(this).attr("label") + ", ";
        
            if ($(this).is(':checked')) {
                var html = '<span title="' + title + '">' + title + '</span>';
                $("#" + id + " .multiSel").append(html);
                $("#" + id + " .hida").hide();
            } 
            else {
                $("#" + id + ' span[title="' + title + '"]').remove();
                var ret = $("#" + id + " .hida");
                if ($("#" + id + ' span[title]').length == 0)
                    ret.show();
                $("#" + id + " dt").append(ret);
            }
        });
    }
);

function getSelectedValue(id) {
    return $("#" + id).find("dt a span.value").html();
}

