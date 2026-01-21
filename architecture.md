# Campus Kin - Lost and Found App Architecture

## Core Features
1. **Post Lost Items** - Users can upload photos and descriptions of lost items
2. **Post Found Items** - Users can upload photos and descriptions of found items
3. **AI Image Comparison** - Automatic matching of lost/found items using visual similarity
4. **Search & Filter** - Manual search by category, location, and date
5. **Contact System** - Users can contact each other about matches
6. **User Profiles** - Basic user information and contact details

## Technical Architecture

### Data Models
- `ItemModel` - Core model for lost/found items
- `UserModel` - User profile information
- `MatchModel` - AI-suggested matches between items

### Key Screens
1. `HomePage` - Dashboard with recent items and quick actions
2. `PostItemScreen` - Form to post lost/found items
3. `SearchScreen` - Search and filter functionality
4. `ItemDetailScreen` - Detailed view of individual items
5. `MatchesScreen` - AI-suggested matches
6. `ProfileScreen` - User profile management

### Services
- `DatabaseService` - Local storage using SharedPreferences and local files
- `ImageService` - Handle image capture, storage, and processing
- `AIService` - Integration with free AI APIs for image comparison
- `MatchingService` - Logic for finding similar items

### Storage Strategy
- **Local Storage**: SharedPreferences for app data, local file system for images
- **No External Backend**: Self-contained app with local data persistence

### AI Integration
- **Hugging Face Inference API** - Free tier for image feature extraction
- **Local Image Comparison** - Client-side similarity scoring
- **Fallback Manual Search** - Traditional search when AI isn't available

## Implementation Priority
1. Core UI and navigation structure
2. Data models and local storage
3. Basic CRUD operations for items
4. Image handling and storage
5. AI integration and matching
6. Search and filtering
7. User profile and contact features