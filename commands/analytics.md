---
description: Manage and query the OpenCode System Analytics dashboard
argument-hint: [start|stop|status|cli|alerts]
---

Manage and query the OpenCode System Analytics dashboard.

Run: `~/tools/orchestrator_analytics/launch.sh $ARGUMENTS`

Behavior:
- **status** (or default): Check if dashboard is running on port 8765.
- **start**: Start the web dashboard in background.
- **stop**: Stop the running dashboard server.
- **cli**: Run the CLI output.
- **alerts**: Report only the actionable findings, newest severity first.

After running the command, report the result to the user.
