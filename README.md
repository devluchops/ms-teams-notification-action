# Custom MS Teams Notification Action

[![GitHub marketplace](https://img.shields.io/badge/marketplace-custom--ms--teams--notification--action-blue?logo=github)](https://github.com/marketplace/actions/custom-ms-teams-notification-action)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Send notifications to Microsoft Teams channels from your GitHub Actions workflows.

## Features

- 🎨 **Smart color coding**: Automatic theme colors based on status (success=green, failure=red, in-progress=yellow)
- 🔗 **Action buttons**: Add clickable links to your notifications
- 🧪 **Testable**: Built-in dry-run mode for testing
- 🔒 **Secure**: Uses Teams webhooks with proper validation

## Quick Start

### 1. Get your Teams webhook URL
Follow [Microsoft's guide](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook) to create a webhook connector in your Teams channel.

### 2. Add webhook to secrets
In your repository: Settings → Secrets and variables → Actions → New repository secret
- Name: `MS_TEAMS_WEBHOOK_URL` 
- Value: Your Teams webhook URL

### 3. Use in workflow

```yaml
- name: Notify Teams
  uses: DevLuchOps/ms-teams-notification-action@v1
  with:
    webhook_url: ${{ secrets.MS_TEAMS_WEBHOOK_URL }}
    title: 'Build Complete'
    message: 'The build has finished successfully!'
```

## Input Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `webhook_url` | ✅ | - | Microsoft Teams webhook URL |
| `title` | ✅ | - | Notification title |
| `message` | ✅ | - | Main notification message |
| `url` | ❌ | - | Custom URL for action button (fallback if no workflow_url) |
| `creator` | ❌ | `${{ github.actor }}` | Person who triggered the event |
| `repo_name` | ❌ | `${{ github.repository }}` | Repository name |
| `workflow_url` | ❌ | Auto-generated | Workflow run URL |
| `mention_user` | ❌ | - | Mention user in Teams (email or Teams user ID) |
| `status` | ❌ | `success` | Status: `success`, `failure`, `in_progress` |
| `theme_color` | ❌ | Auto | Hex color (without #) for message theme |
| `dry_run` | ❌ | `false` | If `true`, prints payload without sending |

## Usage Examples

### Basic Notification

```yaml
- name: Notify Teams
  uses: DevLuchOps/ms-teams-notification-action@v1
  with:
    webhook_url: ${{ secrets.MS_TEAMS_WEBHOOK_URL }}
    title: 'Deployment Complete'
    message: 'Successfully deployed to production'
    status: 'success'
```

### With Action Button

```yaml
- name: Notify Teams with Link
  uses: DevLuchOps/ms-teams-notification-action@v1
  with:
    webhook_url: ${{ secrets.MS_TEAMS_WEBHOOK_URL }}
    title: 'Pull Request Ready'
    message: 'New pull request needs review'
    url: ${{ github.event.pull_request.html_url }}
    status: 'in_progress'
```

### Failure Notification with Mention

```yaml
- name: Notify Teams on Failure
  if: failure()
  uses: DevLuchOps/ms-teams-notification-action@v1
  with:
    webhook_url: ${{ secrets.MS_TEAMS_WEBHOOK_URL }}
    title: 'Build Failed'
    message: 'The build process has failed and needs attention'
    url: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
    mention_user: 'everyone'  # Notify everyone in the channel
    status: 'failure'
```

### Complete Workflow Example

```yaml
name: Deploy and Notify

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy
        id: deploy
        run: |
          # Your deployment commands here
          echo "Deploying..."
      
      - name: Notify Success
        if: success()
        uses: DevLuchOps/ms-teams-notification-action@v1
        with:
          webhook_url: ${{ secrets.MS_TEAMS_WEBHOOK_URL }}
          title: 'Deployment Successful'
          message: 'Successfully deployed to production'
          url: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
          # creator and repo_name are automatically set from GitHub context
          status: 'success'
      
      - name: Notify Failure
        if: failure()
        uses: DevLuchOps/ms-teams-notification-action@v1
        with:
          webhook_url: ${{ secrets.MS_TEAMS_WEBHOOK_URL }}
          title: 'Deployment Failed'
          message: 'Deployment to production failed'
          url: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
          status: 'failure'

  notify-pr:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - name: Notify PR
        uses: DevLuchOps/ms-teams-notification-action@v1
        with:
          webhook_url: ${{ secrets.MS_TEAMS_WEBHOOK_URL }}
          title: 'New Pull Request'
          message: '${{ github.event.pull_request.title }}'
          url: ${{ github.event.pull_request.html_url }}
          status: 'in_progress'
```

## GitHub Actions Integration

The action automatically integrates with GitHub Actions context:

- **`creator`**: Automatically set to `${{ github.actor }}` (the user who triggered the workflow)
- **`repo_name`**: Automatically set to `${{ github.repository }}` (owner/repo-name)
- **`workflow_url`**: Automatically set to the current workflow run URL
- **Action Button**: "View Workflow" button automatically links to the workflow run
- **Common URLs**:
  - Workflow run: `${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}` (default)
  - Pull request: `${{ github.event.pull_request.html_url }}`
  - Commit: `${{ github.event.head_commit.url }}`

### Workflow Events

```yaml
# On push to main
on:
  push:
    branches: [main]

# On pull request
on:
  pull_request:
    types: [opened, synchronize]

# On release
on:
  release:
    types: [published]

# Manual trigger
on:
  workflow_dispatch:
```

## Theme Colors

The action automatically sets colors based on status:
- 🟢 **Success**: Green (`00cc00`)
- 🔴 **Failure**: Red (`ff0000`)
- 🟡 **In Progress**: Yellow (`ffcc00`)
- 🔵 **Default**: Blue (`0076D7`)

You can override with a custom hex color (without #):

```yaml
theme_color: 'purple'  # Custom purple color
```

## User Mentions

You can mention users in Teams notifications using Adaptive Cards format:

### Mention Everyone or Channel
```yaml
mention_user: 'everyone'    # Mentions @everyone
mention_user: 'channel'     # Mentions @channel
```

### Mention Specific User (requires Azure AD ID)
```yaml
mention_user: '8:orgid:12345678-1234-1234-1234-123456789abc|John Doe'
# Format: 8:orgid:AZURE_AD_ID|DisplayName
```

**How to get Azure AD ID:**
1. Use Microsoft Graph API: `GET /users/{userPrincipalName}`
2. PowerShell: `Get-AzureADUser -UserPrincipalName "user@domain.com"`
3. Azure Portal: Azure Active Directory → Users → Select user → Object ID

**Important Notes:**
- User mentions require the full Azure AD ID prefixed with `8:orgid:`
- @everyone and @channel work with webhooks but may have limited notification capability
- The user must be part of the Teams channel to receive notifications
- This works best with Bot context, webhook context has limitations

## Testing

### Local Testing

Since the action runs directly in GitHub Actions, you can test it using dry-run mode:

```yaml
- name: Test Notification
  uses: DevLuchOps/ms-teams-notification-action@v1
  with:
    webhook_url: ${{ secrets.MS_TEAMS_WEBHOOK_URL }}
    title: 'Test'
    message: 'Testing notification'
    dry_run: 'true'  # This will only show the payload without sending
```

### GitHub Actions Testing

Use dry run mode to test your configuration:

```yaml
- name: Test Notification
  uses: DevLuchOps/ms-teams-notification-action@v1
  with:
    webhook_url: ${{ secrets.MS_TEAMS_WEBHOOK_URL }}
    title: 'Test'
    message: 'Testing notification'
    dry_run: 'true'
```

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.