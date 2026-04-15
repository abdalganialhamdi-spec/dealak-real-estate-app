<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;

class FCMService
{
    public function sendToUser(User $user, string $title, string $body, array $data = []): void
    {
        $devices = $user->devices()->where('is_active', true)->get();

        foreach ($devices as $device) {
            $this->send($device->device_token, $title, $body, $data);
        }
    }

    private function send(string $token, string $title, string $body, array $data = []): void
    {
        $projectId = config('services.fcm.project_id');

        if (!$projectId) return;

        Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->getAccessToken(),
            'Content-Type' => 'application/json',
        ])->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", [
            'message' => [
                'token' => $token,
                'notification' => compact('title', 'body'),
                'data' => $data,
            ],
        ]);
    }

    private function getAccessToken(): string
    {
        return config('services.fcm.server_key', '');
    }
}
