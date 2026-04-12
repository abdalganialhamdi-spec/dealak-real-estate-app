export default function LoadingState({ message = 'جاري التحميل...' }: { message?: string }) {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center" role="status" aria-live="polite">
      <div className="text-center">
        <div
          className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"
          aria-hidden="true"
        ></div>
        <p className="text-gray-600">{message}</p>
      </div>
    </div>
  );
}
