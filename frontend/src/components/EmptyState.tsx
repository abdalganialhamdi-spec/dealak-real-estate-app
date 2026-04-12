export default function EmptyState({ message = 'لا توجد بيانات', icon = '📭' }: { message?: string; icon?: string }) {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center" role="status" aria-live="polite">
      <div className="text-center">
        <div className="text-6xl mb-4" aria-hidden="true">{icon}</div>
        <p className="text-gray-600">{message}</p>
      </div>
    </div>
  );
}
