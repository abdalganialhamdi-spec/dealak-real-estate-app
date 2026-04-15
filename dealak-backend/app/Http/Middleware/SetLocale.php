<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class SetLocale
{
    public function handle(Request $request, Closure $next)
    {
        $locale = $request->header('Accept-Language', config('app.locale', 'ar'));
        app()->setLocale(in_array($locale, ['ar', 'en']) ? $locale : 'ar');
        return $next($request);
    }
}
