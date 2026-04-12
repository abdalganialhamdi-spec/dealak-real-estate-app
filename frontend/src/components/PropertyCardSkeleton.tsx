export default function PropertyCardSkeleton() {
  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden" role="status" aria-live="polite" aria-busy="true">
      <div className="h-48 bg-gray-200 animate-pulse" aria-hidden="true"></div>
      <div className="p-4">
        <div className="h-6 bg-gray-200 rounded animate-pulse mb-2" aria-hidden="true"></div>
        <div className="h-4 bg-gray-200 rounded animate-pulse mb-3 w-3/4" aria-hidden="true"></div>
        <div className="flex gap-4 mb-3">
          <div className="h-4 bg-gray-200 rounded animate-pulse w-1/4" aria-hidden="true"></div>
          <div className="h-4 bg-gray-200 rounded animate-pulse w-1/4" aria-hidden="true"></div>
          <div className="h-4 bg-gray-200 rounded animate-pulse w-1/4" aria-hidden="true"></div>
        </div>
        <div className="flex justify-between items-center">
          <div className="h-6 bg-gray-200 rounded animate-pulse w-1/2" aria-hidden="true"></div>
          <div className="h-4 bg-gray-200 rounded animate-pulse w-1/4" aria-hidden="true"></div>
        </div>
      </div>
    </div>
  );
}
