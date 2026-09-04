import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inneed/Models/chat_message_model.dart';
class FirstAidProvider extends ChangeNotifier{
  //message list and loading status
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  final String _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';

  //for sending messages and getting response from ai
  Future<void> sendMessage(String userPrompt) async {
    if (userPrompt.trim().isEmpty) return;

    _messages.add(ChatMessage(text: userPrompt, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

      //  OpenRouter REST API Request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "openai/gpt-3.5-turbo",
          "max_tokens": 180,
          "messages": [
            {
              "role": "system",
              "content": "You are IN NEED First Aid Assistant.\n"
                  "Your role is STRICTLY bounded to providing first aid guidance and medical emergency assistance.\n\n"
                  "STRICT RESPONSE FORMAT RULES:\n"
                  "1. Every response MUST contain TWO sections: First section in English, followed by second section in Roman Urdu.\n"
                  "2. ALWAYS start English section with: \"If someone needs help, follow these steps:\"\n"
                  "3. ALWAYS start Urdu section below with: \"Agar kisi ko madad ki zaroorat ho, to yeh tareeqay follow karein:\"\n"
                  "4. DO NOT use any asterisks (*), hashes (#), or bullet dashes (-). Use simple numbers (1., 2., 3.) only.\n"
                  "5. Keep steps short, direct, and limited to 5 main points.\n"
                  "6. End with a short reminder to call 1122 for emergencies.\n\n"
                  "EXACT OUTPUT FORMAT TO FOLLOW FOR EVERY QUERY:\n\n"
                  "If someone is [condition], follow these steps:\n"
                  "1. [Step 1 in English]\n"
                  "2. [Step 2 in English]\n"
                  "3. [Step 3 in English]\n"
                  "4. [Step 4 in English]\n"
                  "5. [Step 5 in English]\n"

                  "Call 1122 immediately for severe emergencies.\n\n"
                  "Agar kisi ko [condition in Roman Urdu], to yeh tareeqay follow karein:\n"

                  "1. [Step 1 in Roman Urdu]\n"
                  "2. [Step 2 in Roman Urdu]\n"
                  "3. [Step 3 in Roman Urdu]\n"
                  "4. [Step 4 in Roman Urdu]\n"
                  "5. [Step 5 in Roman Urdu]\n"

                  "Zaroorat barhne par 1122 par call karein."

            },
            {"role": "user", "content": userPrompt}
          ]
        }),
      );
      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);
        final String aiReply = (data['choices'][0]['message']['content'] ?? "")
            .toString()
            .replaceAll('*', '')
            .replaceAll('#', '')
            .trim();

        _messages.add(ChatMessage(text: aiReply, isUser: false));
      } else {
        _messages.add(
          ChatMessage(
            text: "⚠️ Error connecting to assistant: Server returned status ${response.statusCode}",
            isUser: false,
          ),
        );
      }
    } catch (e) {
      _messages.add(
        ChatMessage(
          text: "⚠️ Network error. Please check your connection or call emergency services immediately.",
          isUser: false
        ),
      );
    } finally {
      // for refreshing ui
      _isLoading = false;
      notifyListeners();
    }
  }

  // for clearing chat
  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}