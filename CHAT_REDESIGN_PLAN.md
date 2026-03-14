# Chat Page Redesign Implementation Plan

## Requirements Summary

### 1. AppBar Redesign
- [ ] Change background color (not blue)
- [ ] Reduce back icon size
- [ ] Modern, clean design
- [ ] Better contrast with content

### 2. Input Bar Redesign
- [ ] Remove audio icon from left side
- [ ] Expand input field width
- [ ] Show audio button when input is empty
- [ ] Show send button when input has text
- [ ] Smooth transition between audio/send button

### 3. Audio Recording Feature
- [ ] Long press audio button to start recording
- [ ] Show waveform UI while recording
- [ ] Release to stop recording
- [ ] Show recorded audio with:
  - Waveform visualization
  - Play button (left)
  - Send button (right)
  - Delete button (right)
- [ ] Play/pause functionality for preview

### 4. Message Timestamps
- [ ] Add time display to all messages
- [ ] Small font size
- [ ] Position in corner of message bubble

### 5. Image Picker Bottom Sheet
- [ ] Full-height bottom sheet
- [ ] Close (X) button
- [ ] Camera option (first item, same size as images)
- [ ] Gallery grid of all images
- [ ] Image selection functionality

### 6. Dark Mode Fixes
- [ ] Fix input text color in dark mode
- [ ] Ensure all text is visible in both modes

## Implementation Steps

1. Update AppBar design
2. Redesign input bar with conditional button
3. Add audio recording state management
4. Implement audio recording UI
5. Add timestamps to messages
6. Create image picker bottom sheet
7. Fix dark mode text colors
8. Test all functionality

## Files to Modify

- `lib/features/chat/presentation/pages/chat_page.dart` - Main UI
- `lib/features/chat/presentation/managers/chat_state.dart` - Add audio recording state
- `lib/features/chat/presentation/managers/chat_event.dart` - Add audio events
- `lib/features/chat/presentation/managers/chat_bloc.dart` - Handle audio logic
- `lib/features/chat/domain/entities/chat_message_entity.dart` - Add timestamp field
