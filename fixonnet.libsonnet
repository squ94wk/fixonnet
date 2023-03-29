local f = import 'f.libsonnet';
local fn = import 'fn.libsonnet';

{
  f: f,
  fn: fn + {
    drop:: function() function(x) f({}),
  },
  matchers: import 'matchers.libsonnet',
}
