import { Button } from './Button';

interface ErrorStateProps {
  message?: string;
  onRetry?: () => void;
}

export default function ErrorState({ message = 'حدث خطأ', onRetry }: ErrorStateProps) {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center" role="alert" aria-live="assertive">
      <div className="text-center">
        <div className="text-6xl mb-4" aria-hidden="true">⚠️</div>
        <p className="text-red-600 mb-4">{message}</p>
        {onRetry && (
          <Button onClick={onRetry} variant="primary">
            إعادة المحاولة
          </Button>
        )}
      </div>
    </div>
  );
}
