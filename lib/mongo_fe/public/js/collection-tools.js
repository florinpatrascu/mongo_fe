$(function () {
  //todo: refactor for reusing the code
  
  $('#delete-collection-button').live('click', function () {
      _collection_name = $(this).data('collection-name');

      $('#delete-collection-dialog-title').html( _collection_name);      
      $('#confirm-collection-deletion .primary').attr('action', '/databases/' + 
          $(this).data('db-name') + '/collections/' + _collection_name);
  });

  $('#rename-collection-button').live('click', function () {
      _old_name = $(this).data('collection-name');

      $('#rename-collection-dialog .old_collection_name').html( "'"+_old_name+"'?");      
      $('#rename-collection-dialog .primary').attr('action', '/databases/' + 
          $(this).data('db-name') + '/collections/' + _old_name);
  });

  $('#confirm-delete-document').live('click', function () {
      var doc_id = $(this).data('id');
      
      $('#confirm-delete-document-dialog .doc-id').html( "'"+doc_id+"'");      
      $('#confirm-delete-document-dialog .doc-id-field').attr( 'value', doc_id);      
  });

  $('#confirm-delete-index-button').live('click', function () {
      var index_name = $(this).data('index-name');
      
      $('#confirm-delete-index-dialog .index-name').html( "'"+index_name+"'");      
      $('#confirm-delete-index-dialog .index-name-field').attr( 'value', index_name);      
  });

  $('#edit-document').live('click', function () {
      var doc_id = $(this).data('id');
      var doc = $(this).data('doc');
      
      $('#document-update-dialog .doc-id').html( "'"+doc_id+"'");      
      $('#document-update-dialog .doc-id-field').attr( 'value', doc_id);      
      $('#document-update-dialog .input-xlarge').attr( 'value', JSON.stringify(doc));      
  });

  $('#json-doc-attributes').live('change', function() {
    var val = $(this).val();
    
    if (val) {
      var json={};
      
      try { 
        json = JSON.parse(val); 
        // $('#new-document-modal-submit-button').removeClass('disabled');
        $('#json-doc-attributes-msg').fadeOut('slow');
        
      }catch (e) { 
        //console.log('Error in parsing json. ' + e); 
        $('#json-doc-attributes-msg').fadeIn('slow');
      }
    } else {
        json = {};
    }
  });
  
});