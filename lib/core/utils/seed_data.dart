import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static Future<void> addTestArtisans(FirebaseFirestore firestore) async {
    // Define 10 artisans with matching user data
    final data = [
      {
        'userId': 'artisan_001',
        'name': 'Chidi Okonkwo',
        'email': 'chidi@example.com',
        'phone': '+2348012345678',
        'profession': 'Electrician',
        'bio':
            'Certified electrician with 12 years of experience. Specializing in residential and commercial wiring, installation, and repairs.',
        'experienceYears': 12,
        'serviceArea': 'Lagos Mainland',
        'rating': 4.8,
        'profileImage':
            'https://ui-avatars.com/api/?name=Chidi+Okonkwo&background=6C63FF&color=fff&size=128',
      },
      {
        'userId': 'artisan_002',
        'name': 'Amina Yusuf',
        'email': 'amina@example.com',
        'phone': '+2348023456789',
        'profession': 'Plumber',
        'bio':
            'Expert plumber with 15 years of experience. Specializes in pipe installation, repairs, and water system maintenance.',
        'experienceYears': 15,
        'serviceArea': 'Abuja FCT',
        'rating': 4.9,
        'profileImage':
            'https://ui-avatars.com/api/?name=Amina+Yusuf&background=6C63FF&color=fff&size=128',
      },
      {
        'userId': 'artisan_003',
        'name': 'Segun Adebayo',
        'email': 'segun@example.com',
        'phone': '+2348034567890',
        'profession': 'Mechanic',
        'bio':
            'Master mechanic with 10 years of experience. Expert in engine diagnostics, repairs, and maintenance for all vehicle types.',
        'experienceYears': 10,
        'serviceArea': 'Lagos Island',
        'rating': 4.7,
        'profileImage':
            'https://ui-avatars.com/api/?name=Segun+Adebayo&background=6C63FF&color=fff&size=128',
      },
      {
        'userId': 'artisan_004',
        'name': 'Chioma Eze',
        'email': 'chioma@example.com',
        'phone': '+2348045678901',
        'profession': 'Carpenter',
        'bio':
            'Skilled carpenter with 8 years of experience. Specializes in furniture making, cabinetry, and custom woodwork.',
        'experienceYears': 8,
        'serviceArea': 'Ibadan, Oyo State',
        'rating': 4.6,
        'profileImage':
            'https://ui-avatars.com/api/?name=Chioma+Eze&background=6C63FF&color=fff&size=128',
      },
      {
        'userId': 'artisan_005',
        'name': 'Emeka Okafor',
        'email': 'emeka@example.com',
        'phone': '+2348056789012',
        'profession': 'Painter',
        'bio':
            'Professional painter with 7 years of experience. Expert in interior and exterior painting, wall finishes, and color consultation.',
        'experienceYears': 7,
        'serviceArea': 'Lagos Mainland',
        'rating': 4.5,
        'profileImage':
            'https://ui-avatars.com/api/?name=Emeka+Okafor&background=6C63FF&color=fff&size=128',
      },
      {
        'userId': 'artisan_006',
        'name': 'Tony Oji',
        'email': 'tony@example.com',
        'phone': '+2348067890123',
        'profession': 'Welder',
        'bio':
            'Certified welder with 10 years of experience. Specializes in metal fabrication, structural welding, and custom metalwork.',
        'experienceYears': 10,
        'serviceArea': 'Port Harcourt, Rivers State',
        'rating': 4.8,
        'profileImage':
            'https://ui-avatars.com/api/?name=Tony+Oji&background=6C63FF&color=fff&size=128',
      },
      {
        'userId': 'artisan_007',
        'name': 'Fatima Bello',
        'email': 'fatima@example.com',
        'phone': '+2348078901234',
        'profession': 'AC Technician',
        'bio':
            'HVAC technician with 9 years of experience. Expert in air conditioning installation, repairs, and maintenance services.',
        'experienceYears': 9,
        'serviceArea': 'Lagos Island',
        'rating': 4.7,
        'profileImage':
            'https://ui-avatars.com/api/?name=Fatima+Bello&background=6C63FF&color=fff&size=128',
      },
      {
        'userId': 'artisan_008',
        'name': 'Ibrahim Musa',
        'email': 'ibrahim@example.com',
        'phone': '+2348089012345',
        'profession': 'Tiler',
        'bio':
            'Professional tiler with 11 years of experience. Specializes in floor and wall tiling, marble installation, and waterproofing.',
        'experienceYears': 11,
        'serviceArea': 'Abuja FCT',
        'rating': 4.9,
        'profileImage':
            'https://ui-avatars.com/api/?name=Ibrahim+Musa&background=6C63FF&color=fff&size=128',
      },
      {
        'userId': 'artisan_009',
        'name': 'Kunle Akinola',
        'email': 'kunle@example.com',
        'phone': '+2348090123456',
        'profession': 'Bricklayer',
        'bio':
            'Master bricklayer with 18 years of experience. Expert in foundation laying, block work, and building construction.',
        'experienceYears': 18,
        'serviceArea': 'Lagos Mainland',
        'rating': 4.8,
        'profileImage':
            'https://ui-avatars.com/api/?name=Kunle+Akinola&background=6C63FF&color=fff&size=128',
      },
      {
        'userId': 'artisan_010',
        'name': 'Grace Okonkwo',
        'email': 'grace@example.com',
        'phone': '+2348101234567',
        'profession': 'POP Installer',
        'bio':
            'Specialist in POP ceiling installation and decoration. 6 years of experience in residential and commercial projects.',
        'experienceYears': 6,
        'serviceArea': 'Ikeja, Lagos',
        'rating': 4.4,
        'profileImage':
            'https://ui-avatars.com/api/?name=Grace+Okonkwo&background=6C63FF&color=fff&size=128',
      },
    ];

    for (final item in data) {
      final userId = item['userId'] as String;

      // 1. Create user document
      await firestore.collection('users').doc(userId).set({
        'name': item['name'],
        'email': item['email'],
        'phone': item['phone'],
        'role': 'artisan',
        'profileImage': item['profileImage'],
        'location': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Create artisan document
      await firestore.collection('artisans').doc(userId).set({
        'userId': userId,
        'profession': item['profession'],
        'bio': item['bio'],
        'experienceYears': item['experienceYears'],
        'serviceArea': item['serviceArea'],
        'rating': item['rating'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
