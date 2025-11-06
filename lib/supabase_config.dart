import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase API Data
const SUPABASE_URL = 'https://zdsdqyvzaidlfpuhtokb.supabase.co';
const SUPABASE_API_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpkc2RxeXZ6YWlkbGZwdWh0b2tiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyMzg4NTgsImV4cCI6MjA3NjgxNDg1OH0.q6sPCjZZkiR2JnJ3mLfIQqAIvxc62wm1E3PLlpSk5yg';

class SupabaseManager {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_API_KEY,
    );
  }
}