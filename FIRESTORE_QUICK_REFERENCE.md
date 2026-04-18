## Firestore & Offline Support - Quick Reference

### Real-Time Project Streaming
```dart
// In ProjectProvider initialization
void streamProjectsByWard(String wardId) {
  // Projects update automatically in real-time
  // UI rebuilds whenever Firestore data changes
}

// In your widget
@override
void initState() {
  context.read<ProjectProvider>().streamProjectsByWard(wardId);
  super.initState();
}
```

### Real-Time Issue Streaming
```dart
// In IssueProvider initialization
void streamIssuesByWard(String wardId) {
  // Issues update automatically in real-time
  // Offline issues appear immediately in list
}

// In your widget
Consumer<IssueProvider>(
  builder: (context, provider, _) {
    return ListView.builder(
      itemCount: provider.issues.length, // Includes offline issues
      itemBuilder: (context, index) {
        final issue = provider.issues[index];
        final isOffline = issue.id.startsWith('offline_');
        return IssueCard(issue: issue, isOffline: isOffline);
      },
    );
  },
)
```

### Submit Issue (Auto Offline Support)
```dart
final success = await context.read<IssueProvider>().addIssue(
  title: 'Broken Street Light',
  description: 'Street light not working',
  areaName: 'Market Area',
  roadNumber: '123',
  wardId: wardId,
  latitude: location.latitude,
  longitude: location.longitude,
  imageFile: photo,
  // Automatically works online or offline!
);

if (!success) {
  showError('Failed to submit issue');
}
```

### Check & Sync Offline Submissions
```dart
final issueProvider = context.read<IssueProvider>();

if (issueProvider.hasPendingOfflineSubmissions) {
  print('${issueProvider.pendingOfflineCount} issues pending sync');
  
  if (issueProvider.isOnline) {
    await issueProvider.syncOfflineQueue();
    showSnackBar('Synced offline issues');
  }
}
```

### Cache Management
```dart
// Automatic - no action needed
// Cache automatically invalidates after TTL

// Manual clear if needed
await LocalCacheService.instance.removeCache('projects_cache');
```

### Connectivity Integration
```dart
// In your connectivity service listener
void listenToConnectivity() {
  ConnectivityService.instance.onConnectivityChanged.listen((online) {
    context.read<IssueProvider>().setOnlineStatus(online);
    // Auto-sync triggers if online and pending items exist
  });
}
```

### Error Handling
```dart
Consumer<IssueProvider>(
  builder: (context, provider, _) {
    if (provider.error != null) {
      return ErrorWidget(
        message: provider.error!,
        onRetry: () => provider.loadIssues(),
      );
    }
    
    if (provider.isSyncing) {
      return SyncingIndicator();
    }
    
    return IssueList(issues: provider.issues);
  },
)
```

### Firestore Collections
```
projects/
  - id: string
  - name, description, location: string
  - wardId, wardName: string
  - status: "ongoing|planned|completed"
  - progress: 0-100
  - latitude, longitude: number
  - createdAt, updatedAt: ISO8601

issues/
  - _id: string
  - title, description, areaName, roadNumber: string
  - wardId, wardNumber, reportedBy: string
  - imageUrl: string (optional)
  - status: "open|assigned|in_progress|resolved|closed"
  - latitude, longitude: number (optional)
  - createdAt, updatedAt: ISO8601
```

### Offline Issue Status in UI
```dart
// Issue appears immediately with "pending_offline" status
// When synced, status updates to actual status
// Show special badge for offline issues

Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: issue.id.startsWith('offline_') ? Colors.orange : Colors.green,
    ),
  ),
  child: Column(
    children: [
      Text(issue.title),
      if (issue.id.startsWith('offline_'))
        Text('Pending Sync', style: TextStyle(color: Colors.orange)),
    ],
  ),
)
```

### Cache Behavior
```
First Load:
  1. Check LocalCache (SharedPreferences)
  2. If valid → return cached data
  3. If invalid/missing → fetch from Firestore
  4. Store in cache with TTL
  5. Use Firestore's offline persistence as fallback

Offline Mode:
  1. Can't reach Firestore
  2. Use LocalCache (even if expired)
  3. Queue submissions locally
  4. Show "offline mode" indicator

Back Online:
  1. Auto-sync queued submissions
  2. Refresh cache
  3. Clear "offline mode" indicator
```

### Performance Tips
- Use streaming for frequently updated screens
- Use one-time fetch (loadIssues) for background/initialization
- Offline queue automatically syncs on connection restore
- Cache invalidation happens automatically after TTL
- Real-time listeners unsubscribe when provider is disposed

### Debugging
```dart
// Enable detailed logging
print('Online: ${issueProvider.isOnline}');
print('Pending: ${issueProvider.pendingOfflineCount}');
print('Syncing: ${issueProvider.isSyncing}');
print('Error: ${issueProvider.error}');

// Check cache
print(LocalCacheService.instance.hasValidCache('issues_cache'));

// Manual sync
await issueProvider.syncOfflineQueue();
```

### Security Notes
- Update Firestore security rules before deploying
- Default rules: Only authenticated users can read/write their ward's data
- Implement role-based access (admin can see all, users see their ward)
- OAuth2 tokens from backend auth flow used for Firestore authentication

### Troubleshooting

**Real-time updates not working:**
- Verify Firestore is initialized in main.dart
- Check that streamIssuesByWard() is called (not loadIssues)
- Ensure Firestore rules allow read access

**Offline issues not syncing:**
- Check if device actually has internet
- Verify Firestore write permissions
- Look for errors in console

**Cache not working:**
- Verify LocalCacheService is initialized
- Check TTL settings (15 min for issues, 30 min for projects)
- Try manual cache clear if issues persist

**App crashes on startup:**
- Ensure Firebase credentials are configured
- Check that firebase_core/cloud_firestore are installed
- Verify main.dart initialization order
