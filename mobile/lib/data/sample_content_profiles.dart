import '../models/content_profile.dart';

const sampleContentProfiles = <String, ContentProfile>{
  'imzad-rhythms': ContentProfile(
    contentId: 'imzad-rhythms',
    culturalFamilies: ['Tuareg'],
    regions: ['Hoggar', 'Algeria', 'Sahara'],
    languages: ['Tamahaq'],
    topics: ['Music', 'Instrumental', 'Heritage'],
    energy: 'Calm',
    sacredLevel: 'guardian_reviewed',
    isGuardianApproved: true,
  ),
  'agadir-dance': ContentProfile(
    contentId: 'agadir-dance',
    culturalFamilies: ['Shilha / Tashelhit'],
    regions: ['Agadir', 'Morocco'],
    languages: ['Tashelhit'],
    topics: ['Dance', 'Festival', 'Community'],
    energy: 'High',
    sacredLevel: 'public_celebration',
  ),
  'kabyle-poetry': ContentProfile(
    contentId: 'kabyle-poetry',
    culturalFamilies: ['Kabyle'],
    regions: ['Kabylie', 'Algeria', 'Paris'],
    languages: ['Kabyle', 'French'],
    topics: ['Poetry', 'Diaspora', 'Spoken Word'],
    energy: 'Reflective',
    sacredLevel: 'public_celebration',
  ),
  'rif-bread': ContentProfile(
    contentId: 'rif-bread',
    culturalFamilies: ['Rifian'],
    regions: ['Rif', 'Morocco', 'Nador'],
    languages: ['Tarifit'],
    topics: ['Food', 'Heritage', 'Everyday Life'],
    energy: 'Warm',
    sacredLevel: 'household_practice',
  ),
};
