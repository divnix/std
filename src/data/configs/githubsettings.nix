let
  colors = {
    black = "#000000";
    blue = "#1565C0";
    lightBlue = "#64B5F6";
    green = "#4CAF50";
    grey = "#A6A6A6";
    lightGreen = "#81C784";
    gold = "#FDD835";
    orange = "#FB8C00";
    purple = "#AB47BC";
    red = "#F44336";
    yellow = "#FFEE58";
  };
  labels = {
    statuses = {
      abandoned = {
        name = ":running: Status: Abdandoned";
        description = "This issue has been abdandoned";
        color = colors.black;
      };
      accepted = {
        name = ":ok: Status: Accepted";
        description = "This issue has been accepted";
        color = colors.green;
      };
      blocked = {
        name = ":x: Status: Blocked";
        description = "This issue is in a blocking state";
        color = colors.red;
      };
      inProgress = {
        name = ":construction: Status: In Progress";
        description = "This issue is actively being worked on";
        color = colors.grey;
      };
      onHold = {
        name = ":golf: Status: On Hold";
        description = "This issue is not currently being worked on";
        color = colors.red;
      };
      reviewNeeded = {
        name = ":eyes: Status: Review Needed";
        description = "This issue is pending a review";
        color = colors.gold;
      };
    };
    types = {
      bug = {
        name = ":bug: Type: Bug";
        description = "This issue targets a bug";
        color = colors.red;
      };
      story = {
        name = ":scroll: Type: Story";
        description = "This issue targets a new feature through a story";
        color = colors.lightBlue;
      };
      maintenance = {
        name = ":wrench: Type: Maintenance";
        description = "This issue targets general maintenance";
        color = colors.orange;
      };
      question = {
        name = ":grey_question: Type: Question";
        description = "This issue contains a question";
        color = colors.purple;
      };
      security = {
        name = ":cop: Type: Security";
        description = "This issue targets a security vulnerability";
        color = colors.red;
      };
    };
    priorities = {
      critical = {
        name = ":boom: Priority: Critical";
        description = "This issue is prioritized as critical";
        color = colors.red;
      };
      high = {
        name = ":fire: Priority: High";
        description = "This issue is prioritized as high";
        color = colors.orange;
      };
      medium = {
        name = ":star2: Priority: Medium";
        description = "This issue is prioritized as medium";
        color = colors.yellow;
      };
      low = {
        name = ":low_brightness: Priority: Low";
        description = "This issue is prioritized as low";
        color = colors.green;
      };
    };
    effort = {
      "1" = {
        name = ":muscle: Effort: 1";
        description = "This issue is of low complexity or very well understood";
        color = colors.green;
      };
      "2" = {
        name = ":muscle: Effort: 3";
        description = "This issue is of medium complexity or only partly well understood";
        color = colors.yellow;
      };
      "5" = {
        name = ":muscle: Effort: 5";
        description = "This issue is of high complexity or just not yet well understood";
        color = colors.red;
      };
    };
  };

  l = builtins;
in {
  data = {
    labels =
      []
      ++ (l.attrValues labels.statuses)
      ++ (l.attrValues labels.types)
      ++ (l.attrValues labels.priorities)
      ++ (l.attrValues labels.effort);
  };
}
