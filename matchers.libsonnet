{
  alerts: {
    matchSeverity: function(severity)
      function(rule)
        "alert" in rule && "labels" in rule && "severity" in rule.labels
     && rule.labels.severity == severity,
    matchAlertName: function(name)
      function(rule)
        "alert" in rule
     && rule.alert == name,
  },
  records: {
    matchName: function(name)
      function(rule)
        "record" in rule
     && rule.record == name,
  },
}