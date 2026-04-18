# Firestore Integration & Offline Support Guide

## Overview
The NagarWatch app has been upgraded to use Firebase Firestore with real-time streaming capabilities and comprehensive offline support. This enables:
- **Real-time Data Updates**: Live synchronization of projects and issues across devices
- **Offline Persistence**: Data remains available even without internet connection
- **Offline Submission**: Issues can be submitted offline and synced when connection is restored
- **Smart Caching**: Local cache with TTL-based expiration for optimal performance

---

## Architecture Components

### 1. **FirestoreService** (`lib/core/services/firestore_service.dart`)
Core service for all Firestore operations with offline persistence enabled.

**Key Features:**
- Real-time listeners via `streamCollection()` and `streamIssuesByStatus()`
- One-time fetches via `fetchCollection()`
- Automatic offline persistence configuration
- Query constraint support (==, <, <=, >, >=, array-contains, in)
- Batch operations for complex updates

**Usage:**
```dart
// Real-time stream
FirestoreService.instance.streamCollection<ProjectModel>(
  'projects',
  fromJson: (data, id) => ProjectModel.fromMap({...data, 'id': id}),
  where: [QueryConstraint(field: 'wardId', value: wardId, operator: '==')],
  orderBy: 'createdAt',
  descending: true,
);

// One-time fetch
final projects = await FirestoreService.instance.fetchCollection<ProjectModel>(
  'projects',
  fromJson: (data, id) => ProjectModel.fromMap({...data, 'id': id}),
);
```

### 2. **LocalCacheService** (`lib/core/services/local_cache_service.dart`)
Manages local caching with TTL support and offline queuing.

**Key Features:**
- Cache data with optional TTL (Time-To-Live)
- Queue offline items for later sync
- Check cache validity before using
- Automatic expiration handling

**Usage:**
```dart
// Cache data for 30 minutes
await LocalCacheService.instance.setCache('key', data, ttlMinutes: 30);

// Check if cache is valid
if (LocalCacheService.instance.hasValidCache('key')) {
  final data = LocalCacheService.instance.getCache('key', fromJson: ...);
}

// Queue offline item
await LocalCacheService.instance.queueOfflineItem('issues_queue', id, data);
```

### 3. **ProjectRepository** (`lib/features/project_management/repository/project_repository.dart`)
Converts projects to use Firestore with real-time streaming.

**Methods:**
- `streamAllProjects()` - Real-time stream of all projects
- `streamProjectsByWard(wardId)` - Real-time stream filtered by ward
- `streamProjectsByStatus(wardId, status)` - Real-time stream filtered by status
- `fetchAll()` - One-time fetch with caching
- `fetchByWard(wardId)` - One-time fetch by ward with caching
- `fetchNearby(lat, lng, radiusKm)` - Geofencing support
- `create(project)` - Create new project
- `update(id, updates)` - Update project
- `delete(id)` - Delete project

### 4. **IssueRepository** (`lib/features/evidence_issue_reporting/repository/issue_repository.dart`)
Converts issues to use Firestore with offline submission support.

**Methods:**
- `streamAllIssues()` - Real-time stream of all issues
- `streamIssuesByWard(wardId)` - Real-time stream filtered by ward
- `streamIssuesByStatus(wardId, status)` - Real-time stream filtered by status
- `fetchAll(wardId)` - One-time fetch with caching
- `create(...)` - Create issue (auto-queues if offline)
- `updateStatus(id, status)` - Update issue status
- `updateIssue(id, updates)` - Update issue
- `syncOfflineQueue()` - Manual sync of offline submissions
- `getPendingOfflineCount()` - Get count of pending submissions
- `hasPendingOfflineSubmissions()` - Check if pending items exist

### 5. **ProjectProvider** (`lib/features/project_management/providers/project_provider.dart`)
State management for projects with real-time support.

**Properties:**
- `projects` - Current projects list
- `isLoading` - Loading state
- `isOnline` - Online status
- `error` - Error message

**Methods:**
- `loadProjects(wardId)` - Load projects (one-time, with cache)
- `streamProjectsByWard(wardId)` - Enable real-time streaming
- `streamProjectsByStatus(wardId, status)` - Stream by status
- `createProject(project)` - Create project
- `updateProject(id, updates)` - Update project
- `deleteProject(id)` - Delete project

### 6. **IssueProvider** (`lib/features/evidence_issue_reporting/providers/issue_provider.dart`)
State management for issues with offline submission and real-time support.

**Properties:**
- `issues` - Combined list of offline + online issues
- `isLoading` - Loading state
- `isSyncing` - Sync in progress
- `isOnline` - Online status
- `pendingOfflineCount` - Number of offline submissions
- `hasPendingOfflineSubmissions` - Check if pending

**Methods:**
- `loadIssues(wardId)` - Load issues (one-time, with cache)
- `streamIssuesByWard(wardId)` - Enable real-time streaming
- `streamIssuesByStatus(wardId, status)` - Stream by status
- `addIssue(...)` - Add issue (auto-queues if offline)
- `updateStatus(id, status)` - Update issue status
- `syncOfflineQueue()` - Manual sync
- `clearOfflineQueue()` - Clear pending items
- `setOnlineStatus(online)` - Update connectivity status

---

## Implementation Patterns

### Pattern 1: Real-Time Updates (Recommended for Live Data)
```dart
// In your widget or provider
@override
void initState() {
  super.initState();
  // Start real-time streaming
  context.read<ProjectProvider>().streamProjectsByWard(wardId);
}

// In your build method
Consumer<ProjectProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) return CircularProgressIndicator();
    if (provider.error != null) return Text('Error: ${provider.error}');
    
    return ListView.builder(
      itemCount: provider.projects.length,
      itemBuilder: (context, index) {
        final project = provider.projects[index];
        return ProjectCard(project: project);
      },
    );
  },
)
```

### Pattern 2: One-Time Fetch with Cache
```dart
// For initial load or when you don't need real-time updates
Future<void> loadData() async {
  final projects = await context.read<ProjectProvider>().loadProjects();
  // Data is cached and will be used for offline fallback
}
```

### Pattern 3: Offline Issue Submission
```dart
// Issues automatically queue when offline
final success = await context.read<IssueProvider>().addIssue(
  title: 'Pothole on Main Street',
  description: 'Large pothole near the market',
  areaName: 'Downtown',
  roadNumber: '45',
  wardId: 'ward123',
  // No need to pass isOnline - it's auto-detected
);

if (!success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to submit issue')),
  );
}
```

### Pattern 4: Manual Offline Sync
```dart
// Manually sync offline queue when connectivity is restored
final issueProvider = context.read<IssueProvider>();

if (issueProvider.hasPendingOfflineSubmissions && issueProvider.isOnline) {
  await issueProvider.syncOfflineQueue();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Synced ${issueProvider.pendingOfflineCount} pending issues')),
  );
}
```

### Pattern 5: Connectivity Integration
```dart
// In your connectivity service listener
ConnectivityService.instance.onConnectivityChanged.listen((online) {
  if (online) {
    // When connection restored, update provider and auto-sync
    context.read<IssueProvider>().setOnlineStatus(true);
    // Auto-sync is triggered if there are pending items
  } else {
    context.read<IssueProvider>().setOnlineStatus(false);
  }
});
```

---

## Firestore Collections Schema

### `projects` Collection
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "location": "string",
  "wardId": "string",
  "wardName": "string",
  "status": "ongoing|planned|completed",
  "startDate": "ISO8601",
  "endDate": "ISO8601",
  "budget": "number",
  "progress": "number 0-100",
  "latitude": "number",
  "longitude": "number",
  "createdAt": "ISO8601",
  "updatedAt": "ISO8601"
}
```

### `issues` Collection
```json
{
  "_id": "string",
  "title": "string",
  "description": "string",
  "areaName": "string",
  "roadNumber": "string",
  "wardId": "string",
  "wardNumber": "string",
  "reportedBy": "string",
  "imageUrl": "string",
  "status": "open|assigned|in_progress|resolved|closed",
  "latitude": "number",
  "longitude": "number",
  "createdAt": "ISO8601",
  "updatedAt": "ISO8601"
}
```

---

## Cache Strategy

### Default TTL Values
- Projects: 30 minutes
- Issues: 15 minutes
- Offline queue: No expiration (until synced)

### Cache Keys
```
projects_cache                    # All projects
projects_cache_ward_{wardId}      # Projects by ward
issues_cache                      # All issues
issues_cache_ward_{wardId}        # Issues by ward
queue_issues_queue                # Offline issue submissions
```

### Cache Validation
- Automatic expiration after TTL
- Manual invalidation on create/update/delete
- Fallback to expired cache if no internet

---

## Offline Submission Flow

```
User Submits Issue (Offline)
    ↓
IssueRepository.create() called
    ↓
Network Error? 
    ├─ NO → Create in Firestore → Return issue with id
    └─ YES → Queue locally → Return issue with "offline_timestamp" id
        ↓
LocalCacheService.queueOfflineItem()
    ↓
User sees issue in list with "pending_offline" status
    ↓
Connection Restored
    ↓
IssueProvider.setOnlineStatus(true)
    ↓
Auto-sync triggered (if pending items exist)
    ↓
IssueRepository.syncOfflineQueue()
    ↓
All pending items synced to Firestore
    ↓
IssueProvider updates list
    ↓
UI refreshes with synced status
```

---

## Testing Checklist

- [ ] Real-time updates work for projects
- [ ] Real-time updates work for issues
- [ ] Offline issue submission queues correctly
- [ ] Offline issues display in list with pending status
- [ ] Manual sync clears offline queue
- [ ] Auto-sync triggers when connection restored
- [ ] Cache TTL works correctly
- [ ] Geofencing nearby projects work
- [ ] Image upload handles offline gracefully
- [ ] App works completely offline
- [ ] Firestore offline persistence enabled
- [ ] No errors in logs on startup

---

## Configuration

### Firebase Options
Edit `lib/core/services/firebase_options.dart` to add your Firebase project credentials:
- Android API Key
- iOS API Key
- Web API Key
- Project ID: `nagarwatch-25693`

### Firestore Settings
In `firestore_service.dart`, you can customize:
- `cacheSizeBytes`: Currently `CACHE_SIZE_UNLIMITED`
- `persistenceEnabled`: Currently `true`
- Indexes: Auto-created by Firestore as needed

---

## Troubleshooting

### Issues not syncing offline
- Check `hasPendingOfflineSubmissions` status
- Verify network connection is restored
- Check Firebase project permissions
- Review console logs for sync errors

### Cache not updating
- Verify TTL hasn't expired (check default values)
- Manual clear: `await LocalCacheService.instance.removeCache(key)`
- Check Firestore connectivity

### Real-time updates not working
- Ensure Firestore is initialized before providers
- Check that streaming methods are called (not just fetchAll)
- Verify Firestore rules allow read access
- Check for subscription leaks in widget disposal

### Offline not working
- Verify `persistenceEnabled: true` in Firestore settings
- Check that Firebase is initialized
- Ensure network request didn't complete while offline

---

## Performance Considerations

1. **Streaming vs. One-Time Fetch**
   - Use streaming for frequently updated data (issues, projects in active view)
   - Use one-time fetch for initialization/background loads

2. **Cache TTL**
   - Shorter TTL (15 min) for frequently changing data (issues)
   - Longer TTL (30 min) for stable data (projects)
   - Adjust based on your use case

3. **Firestore Costs**
   - Streaming increases read operations
   - Use collection filtering in Firestore (not client-side where possible)
   - Consider regional Firestore instance

4. **Local Storage**
   - Offline queue stored in SharedPreferences
   - Cache stored in SharedPreferences
   - Total size capped by device storage
   - Monitor for large offline queues

---

## Next Steps

1. Configure Firebase credentials in `firebase_options.dart`
2. Update Firestore security rules for proper access control
3. Test real-time updates with multiple devices
4. Monitor Firestore usage and costs
5. Consider pagination for large datasets
6. Add retry logic for failed offline syncs
7. Implement background sync for issues
