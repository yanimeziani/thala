import '../models/contact_handle.dart';
import '../models/localized_text.dart';
import '../models/message.dart';
import '../models/message_thread.dart';

const String sampleCurrentUserHandle = '@you';

const ContactHandle sampleCurrentUser = ContactHandle(
  handle: sampleCurrentUserHandle,
  displayName: 'You',
  bio: 'Documenting Amazigh culture through sound, story, and archives.',
  location: 'Tizi Ouzou',
  isVerified: true,
);

final List<ContactHandle> sampleContactHandles = <ContactHandle>[
  sampleCurrentUser,
  ContactHandle(
    handle: '@aziza',
    displayName: 'Aziza Taleb',
    bio: 'Elder storyteller & steward of cedar grove gatherings.',
    location: 'Illigh',
  ),
  ContactHandle(
    handle: '@amir',
    displayName: 'Amir Idir',
    bio: 'Multi-instrumentalist keeping village rhythms alive.',
    location: 'At Yenni',
  ),
  ContactHandle(
    handle: '@leila',
    displayName: 'Leila Amour',
    bio: 'Festival co-op & community radio host.',
    location: 'Algiers',
  ),
  ContactHandle(
    handle: '@yassine',
    displayName: 'Yassine Merzouk',
    bio: 'Engineer of soundscapes. Mixing on solar energy.',
    location: 'Akfadou',
  ),
  ContactHandle(
    handle: '@simo',
    displayName: 'Simo Lahcen',
    bio: 'Percussion lead & loop machine tinkerer.',
    location: 'Marrakesh',
  ),
  ContactHandle(
    handle: '@amina',
    displayName: 'Amina B',
    bio: 'Archivist digitizing Amazigh manuscripts.',
    location: 'Tiznit',
  ),
  ContactHandle(
    handle: '@imane',
    displayName: 'Imane R',
    bio: 'Community mentor pairing teens with elders.',
    location: 'Casablanca',
  ),
  ContactHandle(
    handle: '@jawad',
    displayName: 'Jawad Filali',
    bio: 'Field recordist walking the Atlas crest.',
    location: 'Ouarzazate',
  ),
  ContactHandle(
    handle: '@nora',
    displayName: 'Nora T',
    bio: 'Textile artist weaving oral histories into thread.',
    location: 'Azrou',
  ),
];

final Map<String, ContactHandle> sampleHandlesIndex = <String, ContactHandle>{
  for (final ContactHandle handle in sampleContactHandles)
    handle.handle: handle,
};

ContactHandle _lookupHandle(String handle) {
  return sampleHandlesIndex[handle] ??
      ContactHandle(handle: handle, displayName: handle.replaceAll('@', ''));
}

LocalizedText _text(String value) => LocalizedText(en: value, fr: value);

Message _message({
  required String id,
  required String threadId,
  required String authorHandle,
  required DateTime timestamp,
  required String text,
  MessageDeliveryStatus status = MessageDeliveryStatus.read,
}) {
  final ContactHandle author = _lookupHandle(authorHandle);
  return Message(
    id: id,
    threadId: threadId,
    authorHandle: author.handle,
    authorDisplayName: author.displayName,
    text: text,
    createdAt: timestamp,
    deliveryStatus: status,
    isMine: author.handle == sampleCurrentUserHandle,
  );
}

final List<MessageThread> sampleMessageThreads = <MessageThread>[
  MessageThread(
    id: 'thread-001',
    title: LocalizedText(en: 'Village elders', fr: 'Les anciens du village'),
    lastMessage: _text('We are gathering near the cedar grove at dusk.'),
    updatedAt: DateTime(2024, 4, 16, 18, 30),
    unreadCount: 3,
    participants: <String>['@aziza', '@amir'],
    avatarUrl: null,
  ),
  MessageThread(
    id: 'thread-002',
    title: LocalizedText(en: 'Festival co-op', fr: 'Collectif du festival'),
    lastMessage: _text('Soundcheck finished. Sharing the mix in 10 minutes.'),
    updatedAt: DateTime(2024, 4, 16, 17, 45),
    unreadCount: 1,
    participants: <String>['@leila', '@yassine', '@simo'],
    avatarUrl: null,
  ),
  MessageThread(
    id: 'thread-003',
    title: LocalizedText(
      en: 'Guardians of the archive',
      fr: "Gardiens de l'archive",
    ),
    lastMessage: _text('Scan finished. Uploading to the shared drive tonight.'),
    updatedAt: DateTime(2024, 4, 15, 22, 5),
    unreadCount: 0,
    participants: <String>['@amina'],
    avatarUrl: null,
  ),
];

final Map<String, List<Message>> sampleThreadMessages = <String, List<Message>>{
  'thread-001': <Message>[
    _message(
      id: 'msg-001-1',
      threadId: 'thread-001',
      authorHandle: '@amir',
      timestamp: DateTime(2024, 4, 16, 17, 5),
      text: 'Are we meeting at the cedar grove or the plaza?',
    ),
    _message(
      id: 'msg-001-2',
      threadId: 'thread-001',
      authorHandle: sampleCurrentUserHandle,
      timestamp: DateTime(2024, 4, 16, 17, 6),
      text: 'Cedar grove. I will bring the new recordings.',
    ),
    _message(
      id: 'msg-001-3',
      threadId: 'thread-001',
      authorHandle: '@aziza',
      timestamp: DateTime(2024, 4, 16, 18, 12),
      text: 'Grateful. The elders will appreciate hearing the songs.',
    ),
    _message(
      id: 'msg-001-4',
      threadId: 'thread-001',
      authorHandle: '@amir',
      timestamp: DateTime(2024, 4, 16, 18, 30),
      text: 'We are gathering near the cedar grove at dusk.',
    ),
  ],
  'thread-002': <Message>[
    _message(
      id: 'msg-002-1',
      threadId: 'thread-002',
      authorHandle: '@leila',
      timestamp: DateTime(2024, 4, 16, 16, 10),
      text: 'Who has the final tracklist for tonight?',
    ),
    _message(
      id: 'msg-002-2',
      threadId: 'thread-002',
      authorHandle: sampleCurrentUserHandle,
      timestamp: DateTime(2024, 4, 16, 16, 12),
      text: 'Uploading now, hold on.',
    ),
    _message(
      id: 'msg-002-3',
      threadId: 'thread-002',
      authorHandle: '@yassine',
      timestamp: DateTime(2024, 4, 16, 17, 20),
      text: 'Levels are balanced. Crowd is already humming along.',
    ),
    _message(
      id: 'msg-002-4',
      threadId: 'thread-002',
      authorHandle: '@simo',
      timestamp: DateTime(2024, 4, 16, 17, 45),
      text: 'Soundcheck finished. Sharing the mix in 10 minutes.',
    ),
  ],
  'thread-003': <Message>[
    _message(
      id: 'msg-003-1',
      threadId: 'thread-003',
      authorHandle: sampleCurrentUserHandle,
      timestamp: DateTime(2024, 4, 15, 20, 0),
      text: 'Scanner warmed up, starting on the manuscripts.',
    ),
    _message(
      id: 'msg-003-2',
      threadId: 'thread-003',
      authorHandle: '@amina',
      timestamp: DateTime(2024, 4, 15, 22, 5),
      text: 'Scan finished. Uploading to the shared drive tonight.',
    ),
  ],
};

final Map<String, List<String>> sampleThreadAutoReplies =
    <String, List<String>>{
      'thread-001': <String>[
        'I will make sure the tea is ready before you arrive.',
        'The new flute piece you shared is still in my head!',
      ],
      'thread-002': <String>[
        'Mix just landed. Let me know if any levels feel off.',
        'Crowd meters are green—energy is soaring already.',
      ],
      'thread-003': <String>[
        'Uploading a few photos of the manuscripts as well.',
        'Thank you for calibrating the scanner every time.',
      ],
    };
