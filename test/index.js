var nativeExtension = require('../');
var assert = require('assert');

describe('native extension', function() {

  it('should support creating window controller', async function() {
    var obj = new nativeExtension.WindowController(123);
    obj.show();
  });

});
