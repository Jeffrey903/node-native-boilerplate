var nativeExtension = require('../');
var assert = require('assert');

describe('native extension', function() {

  it('should support showing', async function() {
    nativeExtension.show(137045);
  });

  it('should support hiding', async function() {
    nativeExtension.hide();
  });

});
