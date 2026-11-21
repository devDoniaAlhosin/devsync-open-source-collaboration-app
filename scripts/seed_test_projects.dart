// Test Project Seeding Script for DevSync Matching
// Run: dart run scripts/seed_test_projects.dart
//
// This script creates test projects in Firestore for matching feature testing.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  print('🌱 DevSync Test Projects Seeder\n');

  // Initialize Firebase
  print('Initializing Firebase...');
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;
  print('✅ Firebase initialized\n');

  // Test projects with diverse skill sets
  final testProjects = [
    // Flutter/Mobile Projects
    {
      'projectId': 'flutter-toolkit-001',
      'projectName': 'Flutter Dev Toolkit',
      'description':
          'A comprehensive collection of Flutter development utilities, widgets, and helpers for building modern mobile apps.',
      'githubUrl': 'https://github.com/devsync/flutter-toolkit',
      'neededSkills': ['Flutter', 'Dart', 'Material Design'],
      'maintainerId': 'test_maintainer_flutter',
      'status': 'active',
      'tags': ['mobile', 'flutter', 'ui'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'riverpod-example-002',
      'projectName': 'Riverpod State Management Example',
      'description':
          'Clean architecture template using Riverpod for state management with Firebase integration.',
      'githubUrl': 'https://github.com/devsync/riverpod-example',
      'neededSkills': ['Flutter', 'Dart', 'Riverpod', 'Firebase'],
      'maintainerId': 'test_maintainer_flutter',
      'status': 'active',
      'tags': ['mobile', 'flutter', 'state-management'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'flutter-animations-003',
      'projectName': 'Flutter Animations Library',
      'description':
          'Beautiful pre-built animations for Flutter apps. Includes hero transitions, shimmer effects, and more.',
      'githubUrl': 'https://github.com/devsync/flutter-animations',
      'neededSkills': ['Flutter', 'Dart', 'Animation'],
      'maintainerId': 'test_maintainer_flutter',
      'status': 'active',
      'tags': ['mobile', 'flutter', 'animation', 'ui'],
      'createdAt': FieldValue.serverTimestamp(),
    },

    // Web Projects
    {
      'projectId': 'react-dashboard-004',
      'projectName': 'React Admin Dashboard',
      'description':
          'Modern admin dashboard template with charts, tables, and real-time data visualization.',
      'githubUrl': 'https://github.com/devsync/react-dashboard',
      'neededSkills': ['React', 'JavaScript', 'TypeScript', 'CSS'],
      'maintainerId': 'test_maintainer_web',
      'status': 'active',
      'tags': ['web', 'frontend', 'react'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'nextjs-ecommerce-005',
      'projectName': 'Next.js E-commerce',
      'description':
          'Full-featured e-commerce platform built with Next.js, Stripe, and Tailwind CSS.',
      'githubUrl': 'https://github.com/devsync/nextjs-ecommerce',
      'neededSkills': ['Next.js', 'React', 'TypeScript', 'Tailwind'],
      'maintainerId': 'test_maintainer_web',
      'status': 'active',
      'tags': ['web', 'frontend', 'nextjs', 'ecommerce'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'vue-components-006',
      'projectName': 'Vue Component Library',
      'description':
          'Reusable Vue 3 components with TypeScript support and Storybook documentation.',
      'githubUrl': 'https://github.com/devsync/vue-components',
      'neededSkills': ['Vue', 'JavaScript', 'TypeScript', 'CSS'],
      'maintainerId': 'test_maintainer_web',
      'status': 'active',
      'tags': ['web', 'frontend', 'vue', 'component-library'],
      'createdAt': FieldValue.serverTimestamp(),
    },

    // Backend Projects
    {
      'projectId': 'nodejs-api-007',
      'projectName': 'Node.js REST API Boilerplate',
      'description':
          'Production-ready Express.js API with authentication, validation, and PostgreSQL.',
      'githubUrl': 'https://github.com/devsync/nodejs-api',
      'neededSkills': ['Node.js', 'JavaScript', 'Express', 'PostgreSQL'],
      'maintainerId': 'test_maintainer_backend',
      'status': 'active',
      'tags': ['backend', 'api', 'nodejs'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'python-django-008',
      'projectName': 'Django CMS',
      'description':
          'Content Management System built with Django, PostgreSQL, and Redis for caching.',
      'githubUrl': 'https://github.com/devsync/django-cms',
      'neededSkills': ['Python', 'Django', 'PostgreSQL', 'Redis'],
      'maintainerId': 'test_maintainer_backend',
      'status': 'active',
      'tags': ['backend', 'python', 'cms'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'go-microservices-009',
      'projectName': 'Go Microservices',
      'description':
          'Microservices architecture in Go with gRPC, Docker, and Kubernetes support.',
      'githubUrl': 'https://github.com/devsync/go-microservices',
      'neededSkills': ['Go', 'gRPC', 'Docker', 'Kubernetes'],
      'maintainerId': 'test_maintainer_backend',
      'status': 'active',
      'tags': ['backend', 'microservices', 'golang'],
      'createdAt': FieldValue.serverTimestamp(),
    },

    // Data Science/ML Projects
    {
      'projectId': 'python-ml-010',
      'projectName': 'Machine Learning Toolkit',
      'description':
          'Python library with pre-trained models and utilities for common ML tasks.',
      'githubUrl': 'https://github.com/devsync/ml-toolkit',
      'neededSkills': ['Python', 'TensorFlow', 'NumPy', 'Pandas'],
      'maintainerId': 'test_maintainer_ml',
      'status': 'active',
      'tags': ['ml', 'data-science', 'python'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'pytorch-cv-011',
      'projectName': 'PyTorch Computer Vision',
      'description':
          'Computer vision models and tools built with PyTorch for image classification and detection.',
      'githubUrl': 'https://github.com/devsync/pytorch-cv',
      'neededSkills': ['Python', 'PyTorch', 'OpenCV', 'Computer Vision'],
      'maintainerId': 'test_maintainer_ml',
      'status': 'active',
      'tags': ['ml', 'computer-vision', 'pytorch'],
      'createdAt': FieldValue.serverTimestamp(),
    },

    // DevOps/Infrastructure Projects
    {
      'projectId': 'terraform-aws-012',
      'projectName': 'Terraform AWS Modules',
      'description':
          'Reusable Terraform modules for AWS infrastructure with best practices.',
      'githubUrl': 'https://github.com/devsync/terraform-aws',
      'neededSkills': ['Terraform', 'AWS', 'DevOps', 'Infrastructure'],
      'maintainerId': 'test_maintainer_devops',
      'status': 'active',
      'tags': ['devops', 'terraform', 'aws'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'k8s-helm-013',
      'projectName': 'Kubernetes Helm Charts',
      'description':
          'Production-ready Helm charts for common applications on Kubernetes.',
      'githubUrl': 'https://github.com/devsync/k8s-helm',
      'neededSkills': ['Kubernetes', 'Docker', 'Helm', 'DevOps'],
      'maintainerId': 'test_maintainer_devops',
      'status': 'active',
      'tags': ['devops', 'kubernetes', 'helm'],
      'createdAt': FieldValue.serverTimestamp(),
    },

    // Mobile Native Projects
    {
      'projectId': 'android-kotlin-014',
      'projectName': 'Android Kotlin MVVM',
      'description':
          'Modern Android app template using Kotlin, Jetpack Compose, and MVVM architecture.',
      'githubUrl': 'https://github.com/devsync/android-kotlin',
      'neededSkills': ['Kotlin', 'Android', 'Jetpack Compose', 'MVVM'],
      'maintainerId': 'test_maintainer_mobile',
      'status': 'active',
      'tags': ['mobile', 'android', 'kotlin'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'ios-swift-015',
      'projectName': 'iOS SwiftUI App',
      'description':
          'iOS app template with SwiftUI, Combine, and modern Swift patterns.',
      'githubUrl': 'https://github.com/devsync/ios-swift',
      'neededSkills': ['Swift', 'iOS', 'SwiftUI', 'Combine'],
      'maintainerId': 'test_maintainer_mobile',
      'status': 'active',
      'tags': ['mobile', 'ios', 'swift'],
      'createdAt': FieldValue.serverTimestamp(),
    },

    // Multi-skill Projects
    {
      'projectId': 'fullstack-app-016',
      'projectName': 'Full-Stack Social Platform',
      'description':
          'Complete social media platform with React frontend, Node.js backend, and PostgreSQL.',
      'githubUrl': 'https://github.com/devsync/fullstack-app',
      'neededSkills': [
        'React',
        'Node.js',
        'PostgreSQL',
        'TypeScript',
        'Docker'
      ],
      'maintainerId': 'test_maintainer_fullstack',
      'status': 'active',
      'tags': ['fullstack', 'web', 'backend'],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'projectId': 'open-source-crm-017',
      'projectName': 'Open Source CRM',
      'description':
          'Customer relationship management system for small businesses with Flutter mobile app and Django backend.',
      'githubUrl': 'https://github.com/devsync/open-source-crm',
      'neededSkills': ['Flutter', 'Python', 'Django', 'PostgreSQL', 'Firebase'],
      'maintainerId': 'test_maintainer_fullstack',
      'status': 'active',
      'tags': ['fullstack', 'crm', 'mobile', 'backend'],
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  print('📝 Creating ${testProjects.length} test projects...\n');

  int created = 0;
  int failed = 0;

  for (final project in testProjects) {
    try {
      await firestore
          .collection('projects')
          .doc(project['projectId'] as String)
          .set(project);

      print('✅ Created: ${project['projectName']}');
      print('   Skills: ${(project['neededSkills'] as List).join(', ')}');
      print('   Tags: ${(project['tags'] as List).join(', ')}\n');

      created++;
    } catch (e) {
      print('❌ Failed: ${project['projectName']}');
      print('   Error: $e\n');
      failed++;
    }
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ Successfully created $created projects');
  if (failed > 0) {
    print('❌ Failed to create $failed projects');
  }
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  print('🎯 Next steps:');
  print('1. Verify projects in Firebase Console');
  print('2. Run Flutter app: flutter run');
  print('3. Sign in and add matching skills');
  print('4. Generate matches to test\n');

  print('💡 Test with these skill combinations:');
  print('   • Flutter, Dart, Firebase → 3 Flutter projects');
  print('   • React, JavaScript, TypeScript → 3 Web projects');
  print('   • Python, Django, PostgreSQL → 2 Backend projects');
  print('   • Kubernetes, Docker, DevOps → 2 DevOps projects\n');
}
