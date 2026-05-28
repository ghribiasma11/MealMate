<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class TranslationController extends Controller
{
    public function translate(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'source_language' => 'nullable|string|max:10',
            'target_language' => 'required|string|max:10',
            'translations' => 'required|array',
            'translations.*' => 'required|string|max:500',
        ]);

        $sourceLanguage = $validated['source_language'] ?? 'en';
        $targetLanguage = $validated['target_language'];
        $translations = [];

        foreach ($validated['translations'] as $key => $text) {
            if ($sourceLanguage === $targetLanguage) {
                $translations[$key] = $text;
                continue;
            }

            try {
                $response = Http::timeout(10)->get(
                    'https://api.mymemory.translated.net/get',
                    [
                        'q' => $text,
                        'langpair' => "{$sourceLanguage}|{$targetLanguage}",
                    ]
                );

                $translatedText = data_get($response->json(), 'responseData.translatedText');
                $translations[$key] = is_string($translatedText) && $translatedText !== ''
                    ? $translatedText
                    : $text;
            } catch (\Throwable $exception) {
                $translations[$key] = $text;
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'translations' => $translations,
            ],
        ]);
    }
}
