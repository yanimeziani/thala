import '../models/archive_entry.dart';
import '../models/localized_text.dart';

const sampleArchiveEntries = <ArchiveEntry>[
  ArchiveEntry(
    id: 'ancestral-tar',
    title: LocalizedText(
      en: 'Ancestral Tar Artwork',
      fr: 'Œuvre ancestrale du tar',
    ),
    summary: LocalizedText(
      en: 'Exploring embroidered motifs from Aurès artisans preserved since 1920.',
      fr: 'Motifs brodés des artisanes de l\'Aurès conservés depuis 1920.',
    ),
    era: LocalizedText(en: 'Aurès · 1920s', fr: 'Aurès · Années 1920'),
    thumbnailUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80',
    category: 'Textile',
    communityUpvotes: 8200,
    registeredUsers: 12000,
    requiredApprovalPercent: 60,
  ),
  ArchiveEntry(
    id: 'ahwach-oral',
    title: LocalizedText(
      en: 'Ahouach Oral Histories',
      fr: 'Histoires orales ahouach',
    ),
    summary: LocalizedText(
      en: 'Digitised chants celebrating the first harvest moon.',
      fr: 'Chants numérisés célébrant la première lune des récoltes.',
    ),
    era: LocalizedText(en: 'Agadir · 1968', fr: 'Agadir · 1968'),
    thumbnailUrl:
        'https://images.unsplash.com/photo-1523419409543-0c1df022bdd1?auto=format&fit=crop&w=800&q=80',
    category: 'Audio',
    communityUpvotes: 5400,
    registeredUsers: 8600,
    requiredApprovalPercent: 55,
  ),
  ArchiveEntry(
    id: 'blue-tifinagh',
    title: LocalizedText(
      en: 'Indigo Tifinagh Banner',
      fr: 'Bannière tifinagh indigo',
    ),
    summary: LocalizedText(
      en: 'Handwoven banner used in Amazigh student movements.',
      fr: 'Bannière tissée utilisée par les mouvements étudiants amazighs.',
    ),
    era: LocalizedText(en: 'Rabat · 1984', fr: 'Rabat · 1984'),
    thumbnailUrl:
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80',
    category: 'Archive',
    communityUpvotes: 4800,
    registeredUsers: 7000,
    requiredApprovalPercent: 50,
  ),
];
