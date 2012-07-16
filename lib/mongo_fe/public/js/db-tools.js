$(function () {
  // just playing
  $( '#confirm-db-deletion').hide();
  $( '#user-dialog').hide();

  // using the localStorage to store the state of the Info/Docs/Indexes TABs
  var lastTab = localStorage.getItem('lastTabSelected');
  if (lastTab) {
    $('#'+lastTab).tab('show');
    $('div.tab-content').children().removeClass('active in');
    $('#'+lastTab+'-tab').addClass('active in');
  }else{
    $('#collections-info').tab('show');
    $('#collections-info-tab').addClass('active in');
  }

  $('a[data-toggle="tab"]').on('click', function (e) {
    var id = $(e.target).attr('id');
    localStorage.setItem('lastTabSelected', id);
    $('div.tab-content').children().removeClass('active in');
    $(id+'-tab').addClass('active in');    
  });

  $('a.delete-user').live('click', function () {
      _id = $(this).data('id');
      _user_name = $(this).data('user-name');
      _db_name = $(this).data('db-name');

      $('#confirm-delete-user').modal({
          backdrop:true,
          keyboard:true
      });

      $('#delete-dialog-title').html("Delete '" + _user_name + "'?");
      $('#confirm-delete-user .username').attr('value', _user_name);
      $('#confirm-delete-user .primary').attr('action', '/databases/' + _db_name + '/users');
  });


  
  $('#add-collection').live('click', function() {
    $('#new-collection-dialog .primary').attr('action', '/databases/' + 
      $(this).data('db-name') + '/collections');
  });  
});