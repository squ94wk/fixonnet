local f = import './fixonnet.libsonnet';

local rules = [
  {
    record: "rule%d" % i,
    expr: "vector(%d)" % i,
  } for i in std.range(0, 10)
];

local alerts = [
  {
    alert: "alert%d" % i,
    expr: "vector(%d)" % i,
  } for i in std.range(0, 10)
];

local group0 = {
  name: "group0",
  rules: [
    rules[0],
  ],
};

local group1 = {
  name: "group1",
  rules: [
    rules[1],
  ],
};

local group2 = {
  name: "group2",
  rules: [
    rules[2],
    alerts[0],
  ],
};

local mixin0 = {
  rules: {
    groups: [
      group0,
    ],
  },
};

local mixin1 = {
  rules: {
    groups: [
      group2,
    ],
  },
};

local tests = [
  {
    name: "f() retains input",
    expr:: function() f(mixin0),
    test: function(res) res == mixin0,
  },
  {
    name: "drop() returns null",
    expr:: function() f(mixin0).drop(),
    test: function(res) res == null,
  },
  {
    name: "rules.add() adds group",
    expr:: function() f(mixin0).rules.add(group1),
    test: function(res) std.length(res.rules.groups) == 2,
  },
  {
    name: "rules.group(name).rename changes name",
    expr: function() f(mixin0).rules.group("group0").rename("group2"),
    test: function(res) res.rules.groups[0].name == "group2",
  },
  {
    name: "rules.group(name).add(newRule) adds rule",
    expr: function() f(mixin0).rules.group("group0").add(rules[1]),
    test: function(res) std.length(res.rules.groups[0].rules) == 2 && res.rules.groups[0].rules[1] == rules[1],
  },
  {
    name: "rules.group(name).rules(cond).drop() drops rule",
    expr: function() f(mixin1).rules.group("group2").rules(function(rule) "alert" in rule && rule.alert == "alert0").drop(),
    test: function(res) std.length(res.rules.groups[0].rules) == 1,
  },
  {
    name: "rules.group(name).rules(cond).patch(patch) patches rule",
    expr: function() f(mixin1).rules.group("group2").rules(function(rule) "alert" in rule && rule.alert == "alert0").patch({alert: "alert1"}),
    test: [
      function(res) std.length(res.rules.groups[0].rules) == 2,
      function(res) res.rules.groups[0].rules[1].alert == "alert1",
    ],
  },
];

local eval = function(case)
  local value = case.expr();
  {
    name: case.name,
  } + if (std.isArray(case.test) && [] == std.find(false, [test(value) for test in case.test])) || (std.isFunction(case.test) && case.test(value)) then {
    result: 'PASSED',
  } else {
    result: 'FAILED',
    actual: value,
  }
;

[test for test in [
  eval(case) for case in tests
] if test.result == 'FAILED']
